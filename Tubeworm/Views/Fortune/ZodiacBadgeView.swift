import SwiftUI

public struct ZodiacBadgeView: View {
    public let sign: ZodiacSign
    public var isSelected: Bool = false

    public init(sign: ZodiacSign, isSelected: Bool = false) {
        self.sign = sign
        self.isSelected = isSelected
    }

    public var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: isSelected ? [Color.purple.opacity(0.8), Color.indigo.opacity(0.9)] : [Color.white.opacity(0.08), Color.white.opacity(0.03)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 58, height: 58)
                    .overlay(
                        Circle()
                            .stroke(
                                isSelected ? Color.yellow.opacity(0.8) : Color.white.opacity(0.15),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
                    .shadow(color: isSelected ? Color.purple.opacity(0.5) : Color.clear, radius: 8)

                Text(sign.symbol)
                    .font(.system(size: 26))
                    .foregroundColor(isSelected ? .yellow : .white)
            }

            Text(sign.rawValue)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)

            Text(sign.dateRange)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(width: 76)
    }
}
