import Foundation
import Combine

public enum ReadingState: Equatable, Sendable {
    case idle
    case connecting
    case streaming
    case completed(FortuneResult)
    case error(String)
}

public struct ChatMessage: Identifiable, Equatable, Sendable {
    public let id = UUID()
    public let isUser: Bool
    public let content: String
    public let timestamp = Date()
}

@MainActor
public final class FortuneViewModel: ObservableObject {
    @Published public var userProfile: UserProfile
    @Published public var readingState: ReadingState = .idle
    @Published public var streamingContent: String = ""
    @Published public var activeTools: [String] = []
    @Published public var currentReadingResult: FortuneResult?

    @Published public var chatMessages: [ChatMessage] = []
    @Published public var followUpInput: String = ""
    @Published public var isSendingChat: Bool = false
    @Published public var chatError: String?

    private var activeConversationId: UUID?
    private let apiClient = LangGraphAPIClient.shared
    private let storageService = FortuneStorageService.shared

    public init() {
        if let saved = FortuneStorageService.shared.savedProfile {
            self.userProfile = saved
        } else {
            self.userProfile = UserProfile()
        }
    }

    public func updateBirthDate(_ newDate: Date) {
        userProfile.birthDate = newDate
    }

    public func startReading() async {
        guard readingState != .connecting && readingState != .streaming else { return }

        // Save profile
        storageService.saveUserProfile(userProfile)

        readingState = .connecting
        streamingContent = ""
        activeTools = []
        chatMessages = []
        currentReadingResult = nil

        do {
            let convTitle = "西洋占星術鑑定: \(userProfile.nickname) (\(userProfile.zodiacSign.rawValue))"
            let conversationId = try await apiClient.createConversation(title: convTitle)
            self.activeConversationId = conversationId

            self.readingState = .streaming

            let prompt = FortunePromptBuilder.buildInitialReadingPrompt(profile: userProfile)
            var fullOutput = ""

            for try await event in apiClient.streamMessage(conversationId: conversationId, content: prompt) {
                switch event {
                case .started:
                    break
                case .delta(let text):
                    fullOutput += text
                    self.streamingContent = fullOutput
                case .toolStarted(let name, _, _):
                    let toolNameJa = friendlyToolName(name)
                    self.activeTools.append("🔭 \(toolNameJa)を実行中...")
                case .toolCompleted(let name, _, _):
                    let toolNameJa = friendlyToolName(name)
                    self.activeTools.append("✨ \(toolNameJa)の観測完了")
                case .completed(let content):
                    if !content.isEmpty {
                        fullOutput = content
                    }
                case .failed(let detail):
                    throw APIClientError.serverError(statusCode: 500, message: detail)
                case .heartbeat, .unknown:
                    break
                }
            }

            let result = FortuneParser.parse(
                text: fullOutput,
                profile: userProfile,
                conversationId: conversationId,
                toolEvents: activeTools
            )
            self.currentReadingResult = result
            self.readingState = .completed(result)

            // Save to history
            storageService.saveReading(result)

        } catch {
            self.readingState = .error(error.localizedDescription)
        }
    }

    public func sendChatMessage() async {
        let question = followUpInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty, let convId = activeConversationId else { return }

        followUpInput = ""
        isSendingChat = true
        chatError = nil

        let userMsg = ChatMessage(isUser: true, content: question)
        chatMessages.append(userMsg)

        do {
            let prompt = FortunePromptBuilder.buildFollowUpPrompt(userQuestion: question)
            let response = try await apiClient.sendMessage(conversationId: convId, content: prompt)

            let assistantMsg = ChatMessage(isUser: false, content: response.content)
            chatMessages.append(assistantMsg)
        } catch {
            chatError = error.localizedDescription
        }

        isSendingChat = false
    }

    public func reset() {
        readingState = .idle
        streamingContent = ""
        activeTools = []
        currentReadingResult = nil
        chatMessages = []
        activeConversationId = nil
    }

    private func friendlyToolName(_ name: String) -> String {
        switch name {
        case "get_current_datetime": return "天体運行日時"
        case "web_search": return "星の最新運行情報"
        case "calculator": return "天体アスペクト計算"
        default: return name
        }
    }
}
