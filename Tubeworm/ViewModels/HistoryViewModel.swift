import Foundation
import Combine

@MainActor
public final class HistoryViewModel: ObservableObject {
    @Published public private(set) var historyItems: [FortuneResult] = []
    @Published public var selectedItem: FortuneResult?

    private let storageService = FortuneStorageService.shared
    private var cancellables = Set<AnyCancellable>()

    public init() {
        storageService.$history
            .receive(on: RunLoop.main)
            .assign(to: \.historyItems, on: self)
            .store(in: &cancellables)
    }

    public func deleteItem(id: UUID) {
        storageService.deleteReading(id: id)
    }

    public func clearAll() {
        storageService.clearHistory()
    }
}
