import SwiftUI

public struct FortuneInputView: View {
    @ObservedObject var viewModel: FortuneViewModel

    public init(viewModel: FortuneViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Title
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.yellow)
                        Text("星詠みのアトリエ")
                            .font(.system(size: 24, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                        Image(systemName: "sparkles")
                            .foregroundColor(.yellow)
                    }

                    Text("生年月日と本日の天体配置から、あなたの運命を読み解きます")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 16)

                // Zodiac Card Preview
                let sign = viewModel.userProfile.zodiacSign
                VStack(spacing: 12) {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.purple.opacity(0.7), Color.indigo.opacity(0.9)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 64, height: 64)
                                .overlay(
                                    Circle()
                                        .stroke(Color.yellow.opacity(0.7), lineWidth: 1.5)
                                )

                            Text(sign.symbol)
                                .font(.system(size: 32))
                                .foregroundColor(.yellow)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(sign.rawValue)
                                    .font(.system(size: 20, weight: .bold, design: .serif))
                                    .foregroundColor(.white)

                                Text("(\(sign.latinName))")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.6))

                                Spacer()

                                Text(sign.element.rawValue + "エレメント")
                                    .font(.system(size: 11, weight: .medium))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color.white.opacity(0.12))
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                            }

                            Text("守護星: \(sign.rulingPlanet) ｜ \(sign.keywords)")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.75))
                                .lineLimit(1)
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)

                // Form Section
                VStack(alignment: .leading, spacing: 20) {
                    // Nickname
                    VStack(alignment: .leading, spacing: 8) {
                        Label("あなたのお名前（ニックネーム）", systemImage: "person.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))

                        TextField("旅人", text: $viewModel.userProfile.nickname)
                            .padding()
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                            )
                    }

                    // BirthDate Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Label("生年月日", systemImage: "calendar")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))

                        DatePicker(
                            "生年月日",
                            selection: $viewModel.userProfile.birthDate,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.compact)
                        .colorScheme(.dark)
                        .labelsHidden()
                        .padding(.vertical, 4)
                        .padding(.horizontal, 12)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                    }

                    // Category Selector
                    VStack(alignment: .leading, spacing: 8) {
                        Label("特に占いたいテーマ", systemImage: "star.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(FortuneCategory.allCases) { category in
                                    let isSelected = viewModel.userProfile.selectedCategory == category
                                    Button(action: {
                                        viewModel.userProfile.selectedCategory = category
                                    }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: category.icon)
                                                .font(.system(size: 12))
                                            Text(category.rawValue)
                                                .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                                        }
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 10)
                                        .background(
                                            isSelected
                                                ? LinearGradient(colors: [Color.purple, Color.indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
                                                : LinearGradient(colors: [Color.white.opacity(0.07), Color.white.opacity(0.04)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                        )
                                        .foregroundColor(isSelected ? .yellow : .white)
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(isSelected ? Color.yellow.opacity(0.6) : Color.white.opacity(0.1), lineWidth: 1)
                                        )
                                    }
                                }
                            }
                        }
                    }

                    // Custom Question (Optional)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label("気になること・お悩み（任意）", systemImage: "bubble.left.and.bubble.right.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.9))
                            Spacer()
                            Text("自由入力")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.5))
                        }

                        TextField("例: 近々新しいプロジェクトが始まります。運気はどうですか？", text: $viewModel.userProfile.customQuestion, axis: .vertical)
                            .lineLimit(3...5)
                            .padding()
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                            )
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.04))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)

                // Start Button
                Button(action: {
                    Task {
                        await viewModel.startReading()
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.yellow)
                        Text("星を読み解く（今日の運勢を占う）")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color.purple, Color.indigo, Color.blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
                    )
                    .shadow(color: Color.purple.opacity(0.4), radius: 10, y: 4)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
    }
}
