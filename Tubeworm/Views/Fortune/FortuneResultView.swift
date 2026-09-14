import SwiftUI

public struct FortuneResultView: View {
    public let result: FortuneResult
    @ObservedObject var viewModel: FortuneViewModel
    @State private var isShowingFullText: Bool = false

    public init(result: FortuneResult, viewModel: FortuneViewModel) {
        self.result = result
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Score Card
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        // Circular Score Indicator
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.1), lineWidth: 8)
                                .frame(width: 84, height: 84)

                            Circle()
                                .trim(from: 0.0, to: CGFloat(result.score.overall) / 100.0)
                                .stroke(
                                    LinearGradient(
                                        colors: [.purple, .yellow],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .frame(width: 84, height: 84)

                            VStack(spacing: 0) {
                                Text("\(result.score.overall)")
                                    .font(.system(size: 26, weight: .black, design: .rounded))
                                    .foregroundColor(.yellow)
                                Text("運勢指数")
                                    .font(.system(size: 9))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(result.zodiacSign.rawValue)
                                    .font(.system(size: 20, weight: .bold, design: .serif))
                                    .foregroundColor(.white)
                                Text(result.zodiacSign.symbol)
                                    .font(.system(size: 20))
                                    .foregroundColor(.yellow)
                                Spacer()
                                Text(result.category.rawValue)
                                    .font(.system(size: 11, weight: .medium))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color.yellow.opacity(0.2))
                                    .foregroundColor(.yellow)
                                    .cornerRadius(8)
                            }

                            Text("「\(result.headline)」")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                                .lineLimit(2)
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [Color.purple.opacity(0.4), Color.indigo.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.yellow.opacity(0.4), lineWidth: 1.5)
                        )
                )
                .padding(.horizontal, 20)
                .padding(.top, 16)

                // Lucky Elements 2x2 Grid
                VStack(alignment: .leading, spacing: 12) {
                    Label("本日のアストロ・ラッキー要素", systemImage: "sparkles")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.yellow)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        luckyCard(title: "ラッキーカラー", value: result.luckyElements.color, icon: "paintpalette.fill")
                        luckyCard(title: "ラッキーアイテム", value: result.luckyElements.item, icon: "cube.fill")
                        luckyCard(title: "ラッキーナンバー", value: result.luckyElements.number, icon: "number")
                        luckyCard(title: "ラッキーアクション", value: result.luckyElements.action, icon: "figure.walk")
                    }
                }
                .padding(.horizontal, 20)

                // Fortune Scores Breakdown
                VStack(alignment: .leading, spacing: 14) {
                    Label("運気のバイオリズム", systemImage: "chart.bar.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)

                    VStack(spacing: 10) {
                        scoreBar(label: "恋愛運", score: result.score.love, color: .pink)
                        scoreBar(label: "仕事運", score: result.score.career, color: .blue)
                        scoreBar(label: "金運", score: result.score.money, color: .yellow)
                    }
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)

                // Full Reading Text
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Label("星詠み師アストリアの鑑定書", systemImage: "doc.text.fill")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }

                    Text(result.fullReadingText)
                        .font(.system(size: 14))
                        .lineSpacing(6)
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)

                // Interactive Consultation Chat with Astria
                VStack(alignment: .leading, spacing: 14) {
                    Label("星詠み師アストリアにさらに相談する", systemImage: "bubble.left.and.exclamationmark.bubble.right.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.yellow)

                    if !viewModel.chatMessages.isEmpty {
                        VStack(spacing: 12) {
                            ForEach(viewModel.chatMessages) { msg in
                                HStack {
                                    if msg.isUser {
                                        Spacer()
                                        Text(msg.content)
                                            .font(.system(size: 13))
                                            .padding(12)
                                            .background(Color.purple.opacity(0.6))
                                            .foregroundColor(.white)
                                            .cornerRadius(12)
                                    } else {
                                        Text(msg.content)
                                            .font(.system(size: 13))
                                            .padding(12)
                                            .background(Color.white.opacity(0.1))
                                            .foregroundColor(.white.opacity(0.95))
                                            .cornerRadius(12)
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }

                    if let err = viewModel.chatError {
                        Text(err)
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                    }

                    HStack(spacing: 8) {
                        TextField("鑑定で気になることを尋ねる...", text: $viewModel.followUpInput)
                            .font(.system(size: 13))
                            .padding(10)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(10)
                            .foregroundColor(.white)

                        Button(action: {
                            Task {
                                await viewModel.sendChatMessage()
                            }
                        }) {
                            if viewModel.isSendingChat {
                                ProgressView()
                                    .tint(.yellow)
                                    .frame(width: 36, height: 36)
                            } else {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.yellow)
                            }
                        }
                        .disabled(viewModel.isSendingChat || viewModel.followUpInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)

                // Reset / New Reading Button
                Button(action: {
                    viewModel.reset()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("新しく占い直す")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(20)
                }
                .padding(.bottom, 32)
            }
        }
    }

    private func luckyCard(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(.yellow)
                Text(title)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.6))
            }
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(2)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    private func scoreBar(label: String, score: Int, color: Color) -> some View {
        VStack(spacing: 4) {
            HStack {
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                Text("\(score)点")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(color)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 6)

                    Capsule()
                        .fill(color)
                        .frame(width: proxy.size.width * CGFloat(score) / 100.0, height: 6)
                }
            }
            .frame(height: 6)
        }
    }
}
