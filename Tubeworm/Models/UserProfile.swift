import Foundation

public struct UserProfile: Codable, Equatable, Sendable {
    public var nickname: String
    public var birthDate: Date
    public var selectedCategory: FortuneCategory
    public var customQuestion: String

    public init(
        nickname: String = "旅人",
        birthDate: Date = Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 1)) ?? Date(),
        selectedCategory: FortuneCategory = .general,
        customQuestion: String = ""
    ) {
        self.nickname = nickname
        self.birthDate = birthDate
        self.selectedCategory = selectedCategory
        self.customQuestion = customQuestion
    }

    public var zodiacSign: ZodiacSign {
        ZodiacSign.from(date: birthDate)
    }

    public var formattedBirthDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月d日"
        return formatter.string(from: birthDate)
    }
}
