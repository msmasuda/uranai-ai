import SwiftUI

public struct FortuneReadingView: View {
    @ObservedObject var viewModel: FortuneViewModel
    @State private var isRotating = false

    public init(viewModel: FortuneViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 24) {
                    // Mystical Star Animation Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .stroke(
                                    AngularGradient(
                                        gradient: Gradient(colors: [.purple, .indigo, .yellow, .purple]),
                                        center: .center
                                    ),
                                    lineWidth: 3
                                )
                                .frame(width: 80, height: 80)
                                .rotationEffect(Angle(degrees: isRotating ? 360 : 0))
                                .animation(
                                    Animation.linear(duration: 8).repeatForever(autoreverses: false),
                                    value: isRotating
                                )

                            Image(systemName: "sparkle")
                                .font(.system(size: 32))
                                .foregroundColor(.yellow)
                        }
                        .padding(.top, 30)

                        VStack(spacing: 6) {
                            Text(viewModel.readingState == .connecting ? "天界への扉を開いています..." : "星々のメッセージを受信中...")
                                .font(.system(size: 18, weight: .bold, design: .serif))
                                .foregroundColor(.white)

                            Text("\(viewModel.userProfile.nickname) 様の太陽星座「\(viewModel.userProfile.zodiacSign.rawValue)」の星巡りを鑑定中")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }

                    // Active Tools Status List
                    if !viewModel.activeTools.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "gearshape.arrow.triangle.2.circlepath")
                                    .font(.system(size: 12))
                                    .foregroundColor(.yellow)
                                Text("AIエージェントの観測ログ")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.yellow)
                            }

                            ForEach(viewModel.activeTools, id: \.self) { tool in
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(Color.yellow.opacity(0.8))
                                        .frame(width: 6, height: 6)
                                    Text(tool)
                                        .font(.system(size: 12))
                                        .foregroundColor(.white.opacity(0.85))
                                }
                            }
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.purple.opacity(0.15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 20)
                    }

                    // Streaming Text Content Box
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "quote.opening")
                                .foregroundColor(.yellow.opacity(0.7))
                            Text("アストリアの託宣")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            Spacer()
                            ProgressView()
                                .tint(.yellow)
                                .scaleEffect(0.8)
                        }

                        Text(viewModel.streamingContent.isEmpty ? "星々の配置を計算しています..." : viewModel.streamingContent)
                            .font(.system(size: 15, weight: .regular))
                            .lineSpacing(6)
                            .foregroundColor(.white.opacity(0.95))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .id("bottomID")
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .onChange(of: viewModel.streamingContent) { _ in
                withAnimation {
                    proxy.scrollTo("bottomID", anchor: .bottom)
                }
            }
        }
        .onAppear {
            isRotating = true
        }
    }
}
