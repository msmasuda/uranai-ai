import SwiftUI

public struct FortuneHomeView: View {
    @StateObject private var viewModel = FortuneViewModel()

    public init() {}

    public var body: some View {
        ZStack {
            MysticBackground()

            VStack(spacing: 0) {
                switch viewModel.readingState {
                case .idle:
                    FortuneInputView(viewModel: viewModel)
                case .connecting, .streaming:
                    FortuneReadingView(viewModel: viewModel)
                case .completed(let result):
                    FortuneResultView(result: result, viewModel: viewModel)
                case .error(let message):
                    errorCard(message: message)
                }
            }
        }
    }

    private func errorCard(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 44))
                .foregroundColor(.orange)

            Text("星の交信が途絶えました")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)

            Text(message)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Text("バックエンドサーバー (langgraph_sample) が起動しているか「設定」タブから確認してください。")
                .font(.system(size: 12))
                .foregroundColor(.yellow.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Button(action: {
                viewModel.reset()
            }) {
                Text("もう一度試す")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.purple)
                    .cornerRadius(12)
            }
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
        .padding(.horizontal, 24)
    }
}
