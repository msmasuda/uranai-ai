import Foundation

public enum APIClientError: LocalizedError, Sendable {
    case invalidURL
    case serverError(statusCode: Int, message: String)
    case decodingError(String)
    case networkError(String)
    case backendNotReady(String)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "無効なサーバーURLです。"
        case .serverError(let code, let msg):
            return "サーバーエラー (\(code)): \(msg)"
        case .decodingError(let msg):
            return "データの解読に失敗しました: \(msg)"
        case .networkError(let msg):
            return "ネットワーク接続に失敗しました: \(msg)"
        case .backendNotReady(let msg):
            return "バックエンドサーバーの準備ができていません: \(msg)"
        }
    }
}

public final class LangGraphAPIClient: Sendable {
    public static let shared = LangGraphAPIClient()

    private init() {}

    private func getBaseURL() -> URL? {
        let urlString = UserDefaults.standard.string(forKey: "app_backend_base_url") ?? "http://127.0.0.1:8000"
        return URL(string: urlString)
    }

    public func checkHealth(baseURLString: String? = nil) async throws -> Bool {
        let base = baseURLString ?? UserDefaults.standard.string(forKey: "app_backend_base_url") ?? "http://127.0.0.1:8000"
        guard let url = URL(string: "\(base)/health") else {
            throw APIClientError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 5.0

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            return false
        }
        if let decoded = try? JSONDecoder().decode(APIHealthResponse.self, from: data) {
            return decoded.status == "ok"
        }
        return true
    }

    public func checkReady(baseURLString: String? = nil) async throws -> APIReadyResponse {
        let base = baseURLString ?? UserDefaults.standard.string(forKey: "app_backend_base_url") ?? "http://127.0.0.1:8000"
        guard let url = URL(string: "\(base)/ready") else {
            throw APIClientError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 5.0

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw APIClientError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 500, message: "Ready check failed")
        }

        do {
            return try JSONDecoder().decode(APIReadyResponse.self, from: data)
        } catch {
            throw APIClientError.decodingError(error.localizedDescription)
        }
    }

    public func createConversation(title: String = "占いセッション") async throws -> UUID {
        guard let base = getBaseURL(), let url = URL(string: "/v1/conversations", relativeTo: base) else {
            throw APIClientError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["title": title]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let errorText = String(data: data, encoding: .utf8) ?? "Unknown"
            throw APIClientError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 500, message: errorText)
        }

        let conv = try JSONDecoder().decode(APIConversationResponse.self, from: data)
        return conv.id
    }

    public func sendMessage(conversationId: UUID, content: String) async throws -> APIMessageResponse {
        guard let base = getBaseURL(),
              let url = URL(string: "/v1/conversations/\(conversationId.uuidString)/messages", relativeTo: base) else {
            throw APIClientError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(UUID().uuidString, forHTTPHeaderField: "Idempotency-Key")
        request.setValue(UUID().uuidString, forHTTPHeaderField: "X-Request-ID")
        request.timeoutInterval = 120.0

        let body = ["content": content]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let errorText = String(data: data, encoding: .utf8) ?? "Unknown"
            throw APIClientError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 500, message: errorText)
        }

        return try JSONDecoder().decode(APIMessageResponse.self, from: data)
    }

    public func streamMessage(conversationId: UUID, content: String) -> AsyncThrowingStream<SSEStreamingEvent, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    guard let base = getBaseURL(),
                          let url = URL(string: "/v1/conversations/\(conversationId.uuidString)/messages/stream", relativeTo: base) else {
                        continuation.finish(throwing: APIClientError.invalidURL)
                        return
                    }

                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
                    request.setValue(UUID().uuidString, forHTTPHeaderField: "Idempotency-Key")
                    request.setValue(UUID().uuidString, forHTTPHeaderField: "X-Request-ID")
                    request.timeoutInterval = 180.0

                    let body = ["content": content]
                    request.httpBody = try JSONSerialization.data(withJSONObject: body)

                    let (asyncBytes, response) = try await URLSession.shared.bytes(for: request)
                    guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 500
                        continuation.finish(throwing: APIClientError.serverError(statusCode: statusCode, message: "SSE stream connection failed"))
                        return
                    }

                    var currentEvent = ""
                    var currentData = ""

                    for try await line in asyncBytes.lines {
                        if Task.isCancelled { break }

                        if line.hasPrefix(": stream-heartbeat") || line.hasPrefix(":") {
                            continuation.yield(.heartbeat)
                            continue
                        }

                        if line.hasPrefix("event: ") {
                            currentEvent = String(line.dropFirst(7)).trimmingCharacters(in: .whitespaces)
                        } else if line.hasPrefix("data: ") {
                            let dataLine = String(line.dropFirst(6))
                            if currentData.isEmpty {
                                currentData = dataLine
                            } else {
                                currentData += "\n" + dataLine
                            }
                        } else if line.isEmpty {
                            // Empty line terminates an SSE event block
                            if !currentEvent.isEmpty || !currentData.isEmpty {
                                if let event = self.parseEvent(type: currentEvent, rawJson: currentData) {
                                    continuation.yield(event)
                                    if case .completed = event {
                                        continuation.finish()
                                        return
                                    } else if case .failed(let err) = event {
                                        continuation.finish(throwing: APIClientError.serverError(statusCode: 500, message: err))
                                        return
                                    }
                                }
                            }
                            currentEvent = ""
                            currentData = ""
                        }
                    }

                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }

    private func parseEvent(type: String, rawJson: String) -> SSEStreamingEvent? {
        guard let data = rawJson.data(using: .utf8) else {
            return .unknown(type: type, rawData: rawJson)
        }

        switch type {
        case "message.started":
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let msgId = json["message_id"] as? String,
               let convId = json["conversation_id"] as? String {
                return .started(messageId: msgId, conversationId: convId)
            }

        case "assistant.delta":
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let delta = json["delta"] as? String {
                return .delta(text: delta)
            }

        case "tool.started":
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let name = json["name"] as? String,
               let callId = json["tool_call_id"] as? String {
                let argsDict = (try? JSONDecoder().decode([String: AnyCodableValue].self, from: JSONSerialization.data(withJSONObject: json["args"] ?? [:]))) ?? [:]
                return .toolStarted(name: name, toolCallId: callId, args: argsDict)
            }

        case "tool.completed":
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let name = json["name"] as? String,
               let callId = json["tool_call_id"] as? String {
                let output = json["output"] as? String
                return .toolCompleted(name: name, toolCallId: callId, output: output)
            }

        case "message.completed":
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let content = json["content"] as? String {
                return .completed(content: content)
            }

        case "message.failed":
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let detail = json["detail"] as? String ?? json["message"] as? String {
                return .failed(detail: detail)
            }
            return .failed(detail: rawJson)

        default:
            return .unknown(type: type, rawData: rawJson)
        }

        return .unknown(type: type, rawData: rawJson)
    }
}
