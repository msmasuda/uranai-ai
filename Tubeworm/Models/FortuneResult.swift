import Foundation

public struct FortuneScore: Codable, Equatable, Sendable {
    public var overall: Int // 1..100
    public var love: Int // 1..100
    public var career: Int // 1..100
    public var money: Int // 1..100

    public init(overall: Int = 85, love: Int = 80, career: Int = 85, money: Int = 80) {
        self.overall = overall
        self.love = love
        self.career = career
        self.money = money
    }
}

public struct LuckyElements: Codable, Equatable, Sendable {
    public var color: String
    public var item: String
    public var number: String
    public var action: String

    public init(
        color: String = "ラピスラズリブルー",
        item: String = "星モチーフのノート",
        number: String = "7",
        action: String = "朝に一杯の白湯を飲む"
    ) {
        self.color = color
        self.item = item
        self.number = number
        self.action = action
    }
}

public struct FortuneResult: Identifiable, Codable, Equatable, Sendable {
    public var id: UUID
    public var conversationId: UUID?
    public var createdAt: Date
    public var userName: String
    public var zodiacSign: ZodiacSign
    public var category: FortuneCategory
    public var headline: String
    public var fullReadingText: String
    public var score: FortuneScore
    public var luckyElements: LuckyElements
    public var toolEvents: [String]

    public init(
        id: UUID = UUID(),
        conversationId: UUID? = nil,
        createdAt: Date = Date(),
        userName: String,
        zodiacSign: ZodiacSign,
        category: FortuneCategory,
        headline: String,
        fullReadingText: String,
        score: FortuneScore = FortuneScore(),
        luckyElements: LuckyElements = LuckyElements(),
        toolEvents: [String] = []
    ) {
        self.id = id
        self.conversationId = conversationId
        self.createdAt = createdAt
        self.userName = userName
        self.zodiacSign = zodiacSign
        self.category = category
        self.headline = headline
        self.fullReadingText = fullReadingText
        self.score = score
        self.luckyElements = luckyElements
        self.toolEvents = toolEvents
    }

    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: createdAt)
    }
}
