import Foundation

public struct APIConversationResponse: Codable, Sendable {
    public let id: UUID
    public let title: String
    public let status: String?
    public let created_at: String?
}

public struct APIMessageResponse: Codable, Sendable {
    public let id: UUID
    public let conversation_id: UUID
    public let content: String
    public let tool_events: [APIToolExecution]?
}

public struct APIToolExecution: Codable, Sendable {
    public let name: String
    public let args: [String: AnyCodableValue]?
    public let output: String?
}

public struct APIHealthResponse: Codable, Sendable {
    public let status: String
}

public struct APIReadyResponse: Codable, Sendable {
    public let status: String
    public let ollama: Bool
    public let database: Bool?
}

public enum AnyCodableValue: Codable, Sendable, Equatable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case array([AnyCodableValue])
    case dictionary([String: AnyCodableValue])
    case null

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let val = try? container.decode(Bool.self) {
            self = .bool(val)
        } else if let val = try? container.decode(Int.self) {
            self = .int(val)
        } else if let val = try? container.decode(Double.self) {
            self = .double(val)
        } else if let val = try? container.decode(String.self) {
            self = .string(val)
        } else if let val = try? container.decode([AnyCodableValue].self) {
            self = .array(val)
        } else if let val = try? container.decode([String: AnyCodableValue].self) {
            self = .dictionary(val)
        } else {
            self = .null
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let val):
            try container.encode(val)
        case .int(let val):
            try container.encode(val)
        case .double(let val):
            try container.encode(val)
        case .bool(let val):
            try container.encode(val)
        case .array(let val):
            try container.encode(val)
        case .dictionary(let val):
            try container.encode(val)
        case .null:
            try container.encodeNil()
        }
    }
}

public enum SSEStreamingEvent: Sendable {
    case started(messageId: String, conversationId: String)
    case delta(text: String)
    case toolStarted(name: String, toolCallId: String, args: [String: AnyCodableValue])
    case toolCompleted(name: String, toolCallId: String, output: String?)
    case completed(content: String)
    case failed(detail: String)
    case heartbeat
    case unknown(type: String, rawData: String)
}
