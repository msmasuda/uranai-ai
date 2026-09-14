import SwiftUI

public struct MysticBackground: View {
    public init() {}

    public var body: some View {
        ZStack {
            // Dark mystical gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.04, blue: 0.15),
                    Color(red: 0.10, green: 0.07, blue: 0.25),
                    Color(red: 0.03, green: 0.02, blue: 0.10)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Subtle glowing starlight circles
            GeometryReader { proxy in
                Circle()
                    .fill(Color(red: 0.45, green: 0.35, blue: 0.85).opacity(0.15))
                    .frame(width: 320, height: 320)
                    .blur(radius: 80)
                    .position(x: proxy.size.width * 0.2, y: proxy.size.height * 0.2)

                Circle()
                    .fill(Color(red: 0.85, green: 0.65, blue: 0.25).opacity(0.12))
                    .frame(width: 260, height: 260)
                    .blur(radius: 70)
                    .position(x: proxy.size.width * 0.85, y: proxy.size.height * 0.7)

                Circle()
                    .fill(Color(red: 0.25, green: 0.55, blue: 0.85).opacity(0.1))
                    .frame(width: 220, height: 220)
                    .blur(radius: 60)
                    .position(x: proxy.size.width * 0.5, y: proxy.size.height * 0.9)
            }
            .ignoresSafeArea()
        }
    }
}
