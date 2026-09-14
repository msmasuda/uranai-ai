import SwiftUI

public struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @State private var selectedItem: FortuneResult?

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                MysticBackground()

                if viewModel.historyItems.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 48))
                            .foregroundColor(.white.opacity(0.3))
                        Text("鑑定の記録はまだありません")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                        Text("「鑑定」タブから今日の運勢を占ってみましょう")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    .padding()
                } else {
                    List {
                        ForEach(viewModel.historyItems) { item in
                            Button(action: {
                                selectedItem = item
                            }) {
                                HStack(spacing: 14) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.purple.opacity(0.5))
                                            .frame(width: 48, height: 48)
                                        Text(item.zodiacSign.symbol)
                                            .font(.system(size: 24))
                                            .foregroundColor(.yellow)
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(item.zodiacSign.rawValue)
                                                .font(.system(size: 15, weight: .bold))
                                                .foregroundColor(.white)
                                            Text(item.category.rawValue)
                                                .font(.system(size: 11))
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color.white.opacity(0.1))
                                                .foregroundColor(.yellow)
                                                .cornerRadius(6)
                                            Spacer()
                                            Text("\(item.score.overall)点")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(.yellow)
                                        }

                                        Text(item.headline)
                                            .font(.system(size: 12))
                                            .foregroundColor(.white.opacity(0.8))
                                            .lineLimit(1)

                                        Text(item.formattedDate)
                                            .font(.system(size: 10))
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .listRowBackground(Color.white.opacity(0.04))
                            .listRowSeparatorTint(Color.white.opacity(0.1))
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let item = viewModel.historyItems[index]
                                viewModel.deleteItem(id: item.id)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("鑑定の記憶")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !viewModel.historyItems.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(role: .destructive, action: {
                            viewModel.clearAll()
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red.opacity(0.8))
                        }
                    }
                }
            }
            .sheet(item: $selectedItem) { item in
                ZStack {
                    MysticBackground()
                    VStack {
                        HStack {
                            Spacer()
                            Button("閉じる") {
                                selectedItem = nil
                            }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.yellow)
                            .padding()
                        }
                        FortuneResultView(result: item, viewModel: FortuneViewModel())
                    }
                }
            }
        }
    }
}
