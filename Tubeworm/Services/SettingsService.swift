import Foundation
import Combine

@MainActor
public final class SettingsService: ObservableObject {
    public static let shared = SettingsService()

    private let baseURLKey = "app_backend_base_url"
    private let defaultBaseURL = "http://127.0.0.1:8000"

    @Published public var apiBaseURL: String {
        didSet {
            UserDefaults.standard.set(apiBaseURL, forKey: baseURLKey)
        }
    }

    public init() {
        let saved = UserDefaults.standard.string(forKey: baseURLKey)
        self.apiBaseURL = (saved?.isEmpty == false) ? saved! : defaultBaseURL
    }

    public func resetToDefault() {
        self.apiBaseURL = defaultBaseURL
    }
}
