import XCTest
@testable import Tubeworm

final class TubewormTests: XCTestCase {

    func testZodiacSignResolution() {
        let calendar = Calendar(identifier: .gregorian)

        // 牡羊座 (3/21 - 4/19)
        let ariesDate = calendar.date(from: DateComponents(year: 1995, month: 3, day: 25))!
        XCTAssertEqual(ZodiacSign.from(date: ariesDate), .aries)
        XCTAssertEqual(ZodiacSign.aries.element, .fire)

        // 獅子座 (7/23 - 8/22)
        let leoDate = calendar.date(from: DateComponents(year: 1998, month: 8, day: 8))!
        XCTAssertEqual(ZodiacSign.from(date: leoDate), .leo)
        XCTAssertEqual(ZodiacSign.leo.rulingPlanet, "太陽")

        // 蠍座 (10/24 - 11/22)
        let scorpioDate = calendar.date(from: DateComponents(year: 2000, month: 11, day: 5))!
        XCTAssertEqual(ZodiacSign.from(date: scorpioDate), .scorpio)
        XCTAssertEqual(ZodiacSign.scorpio.element, .water)

        // 山羊座 (12/22 - 1/19)
        let capricornDate = calendar.date(from: DateComponents(year: 2000, month: 1, day: 1))!
        XCTAssertEqual(ZodiacSign.from(date: capricornDate), .capricorn)
        XCTAssertEqual(ZodiacSign.capricorn.element, .earth)

        // 魚座 (2/19 - 3/20)
        let piscesDate = calendar.date(from: DateComponents(year: 2002, month: 3, day: 3))!
        XCTAssertEqual(ZodiacSign.from(date: piscesDate), .pisces)
    }

    func testFortunePromptBuilder() {
        let profile = UserProfile(
            nickname: "アリス",
            birthDate: Calendar.current.date(from: DateComponents(year: 1996, month: 7, day: 7))!,
            selectedCategory: .love,
            customQuestion: "新しい出会いはありますか？"
        )

        let prompt = FortunePromptBuilder.buildInitialReadingPrompt(profile: profile)

        XCTAssertTrue(prompt.contains("アリス"))
        XCTAssertTrue(prompt.contains("蟹座"))
        XCTAssertTrue(prompt.contains("恋愛・パートナー運"))
        XCTAssertTrue(prompt.contains("新しい出会いはありますか？"))
        XCTAssertTrue(prompt.contains("get_current_datetime"))
    }

    func testFortuneParser() {
        let sampleOutput = """
        【星の神託】月光に導かれ、秘められた想いが花開くとき
        【総合運気指数】92 / 100
        【本日の天体配置と星読み】金星と木星が調和の角度を形成し、愛の波動が高まっています。
        【重点テーマ運勢：恋愛・パートナー運】素直な言葉が相手の心に届きます。
        【本日のアストロ・ラッキー要素】
        ・ラッキーカラー：ロマンティックローズ
        ・ラッキーアイテム：銀のペンダント
        ・ラッキーナンバー：3
        ・ラッキーアクション：お気に入りの香りをまとう
        【アストリアより贈る言葉】あなたの優しさは光です。自信を持って進んでください。
        """

        let profile = UserProfile(nickname: "アリス")
        let parsed = FortuneParser.parse(text: sampleOutput, profile: profile, conversationId: nil)

        XCTAssertEqual(parsed.headline, "月光に導かれ、秘められた想いが花開くとき")
        XCTAssertEqual(parsed.score.overall, 92)
        XCTAssertEqual(parsed.luckyElements.color, "ロマンティックローズ")
        XCTAssertEqual(parsed.luckyElements.item, "銀のペンダント")
        XCTAssertEqual(parsed.luckyElements.number, "3")
        XCTAssertEqual(parsed.luckyElements.action, "お気に入りの香りをまとう")
    }

    @MainActor
    func testFortuneStorageService() {
        let storage = FortuneStorageService()
        storage.clearHistory()

        let reading = FortuneResult(
            userName: "テストユーザー",
            zodiacSign: .aries,
            category: .general,
            headline: "輝かしい飛躍の日",
            fullReadingText: "テスト本文"
        )

        storage.saveReading(reading)
        XCTAssertEqual(storage.history.count, 1)
        XCTAssertEqual(storage.history.first?.headline, "輝かしい飛躍の日")

        storage.deleteReading(id: reading.id)
        XCTAssertEqual(storage.history.count, 0)
    }

    func testLiveAPIConnectivity() async throws {
        let client = LangGraphAPIClient.shared

        // Live test against the running FastAPI backend
        let isHealthy = try await client.checkHealth(baseURLString: "http://127.0.0.1:8000")
        XCTAssertTrue(isHealthy, "FastAPI /health should return ok")

        let ready = try await client.checkReady(baseURLString: "http://127.0.0.1:8000")
        XCTAssertEqual(ready.status, "ready")
        XCTAssertTrue(ready.ollama, "Ollama should be available")
    }

    func testLiveConversationCreation() async throws {
        let client = LangGraphAPIClient.shared
        let convId = try await client.createConversation(title: "テスト鑑定会話")
        XCTAssertFalse(convId.uuidString.isEmpty, "Conversation UUID should not be empty")
    }
}
