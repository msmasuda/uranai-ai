import Foundation
import Combine

@MainActor
public final class FortuneStorageService: ObservableObject {
    public static let shared = FortuneStorageService()

    private let historyKey = "fortune_reading_history_list"
    private let profileKey = "fortune_saved_user_profile"

    @Published public private(set) var history: [FortuneResult] = []
    @Published public private(set) var savedProfile: UserProfile?

    public init() {
        loadHistory()
        loadProfile()
    }

    public func saveReading(_ reading: FortuneResult) {
        // Prepend to show latest first
        var updated = history
        updated.removeAll { $0.id == reading.id }
        updated.insert(reading, at: 0)
        self.history = updated
        persistHistory()
    }

    public func deleteReading(id: UUID) {
        history.removeAll { $0.id == id }
        persistHistory()
    }

    public func clearHistory() {
        history.removeAll()
        persistHistory()
    }

    public func saveUserProfile(_ profile: UserProfile) {
        self.savedProfile = profile
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: profileKey)
        }
    }

    private func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: historyKey),
              let decoded = try? JSONDecoder().decode([FortuneResult].self, from: data) else {
            self.history = []
            return
        }
        self.history = decoded
    }

    private func persistHistory() {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: historyKey)
        }
    }

    private func loadProfile() {
        guard let data = UserDefaults.standard.data(forKey: profileKey),
              let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) else {
            self.savedProfile = nil
            return
        }
        self.savedProfile = decoded
    }
}
