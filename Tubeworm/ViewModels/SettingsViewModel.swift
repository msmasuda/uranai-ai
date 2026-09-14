import Foundation
import Combine

@MainActor
public final class SettingsViewModel: ObservableObject {
    @Published public var apiBaseURL: String
    @Published public var isChecking: Bool = false
    @Published public var healthStatus: String?
    @Published public var isConnected: Bool = false
    @Published public var isOllamaReady: Bool = false
    @Published public var errorMessage: String?

    private let settingsService = SettingsService.shared
    private let apiClient = LangGraphAPIClient.shared

    public init() {
        self.apiBaseURL = settingsService.apiBaseURL
    }

    public func saveURL() {
        settingsService.apiBaseURL = apiBaseURL.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public func resetURL() {
        settingsService.resetToDefault()
        self.apiBaseURL = settingsService.apiBaseURL
    }

    public func checkConnection() async {
        isChecking = true
        errorMessage = nil
        healthStatus = nil

        let url = apiBaseURL.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            let isHealthy = try await apiClient.checkHealth(baseURLString: url)
            if !isHealthy {
                isConnected = false
                errorMessage = "APIサーバーから正常応答が得られませんでした (/health)"
                isChecking = false
                return
            }

            let readyResponse = try await apiClient.checkReady(baseURLString: url)
            isConnected = true
            isOllamaReady = readyResponse.ollama
            healthStatus = "接続成功 (Ollama: \(readyResponse.ollama ? "正常" : "未起動"), DB: \(readyResponse.database == true ? "接続済" : "未接続/SQLite"))"
            saveURL()
        } catch {
            isConnected = false
            errorMessage = error.localizedDescription
        }

        isChecking = false
    }
}
