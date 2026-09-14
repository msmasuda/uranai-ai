import Foundation

public enum Element: String, Codable, CaseIterable, Sendable {
    case fire = "火"
    case earth = "地"
    case air = "風"
    case water = "水"

    public var englishName: String {
        switch self {
        case .fire: return "Fire"
        case .earth: return "Earth"
        case .air: return "Air"
        case .water: return "Water"
        }
    }

    public var colorHex: String {
        switch self {
        case .fire: return "#FF6B6B"
        case .earth: return "#51CF66"
        case .air: return "#74C0FC"
        case .water: return "#845EF7"
        }
    }
}

public enum ZodiacSign: String, Codable, CaseIterable, Identifiable, Sendable {
    case aries = "牡羊座"
    case taurus = "牡牛座"
    case gemini = "双子座"
    case cancer = "蟹座"
    case leo = "獅子座"
    case virgo = "乙女座"
    case libra = "天秤座"
    case scorpio = "蠍座"
    case sagittarius = "射手座"
    case capricorn = "山羊座"
    case aquarius = "水瓶座"
    case pisces = "魚座"

    public var id: String { rawValue }

    public var symbol: String {
        switch self {
        case .aries: return "♈"
        case .taurus: return "♉"
        case .gemini: return "♊"
        case .cancer: return "♋"
        case .leo: return "♌"
        case .virgo: return "♍"
        case .libra: return "♎"
        case .scorpio: return "♏"
        case .sagittarius: return "♐"
        case .capricorn: return "♑"
        case .aquarius: return "♒"
        case .pisces: return "♓"
        }
    }

    public var latinName: String {
        switch self {
        case .aries: return "Aries"
        case .taurus: return "Taurus"
        case .gemini: return "Gemini"
        case .cancer: return "Cancer"
        case .leo: return "Leo"
        case .virgo: return "Virgo"
        case .libra: return "Libra"
        case .scorpio: return "Scorpio"
        case .sagittarius: return "Sagittarius"
        case .capricorn: return "Capricorn"
        case .aquarius: return "Aquarius"
        case .pisces: return "Pisces"
        }
    }

    public var dateRange: String {
        switch self {
        case .aries: return "3/21 - 4/19"
        case .taurus: return "4/20 - 5/20"
        case .gemini: return "5/21 - 6/21"
        case .cancer: return "6/22 - 7/22"
        case .leo: return "7/23 - 8/22"
        case .virgo: return "8/23 - 9/22"
        case .libra: return "9/23 - 10/23"
        case .scorpio: return "10/24 - 11/22"
        case .sagittarius: return "11/23 - 12/21"
        case .capricorn: return "12/22 - 1/19"
        case .aquarius: return "1/20 - 2/18"
        case .pisces: return "2/19 - 3/20"
        }
    }

    public var element: Element {
        switch self {
        case .aries, .leo, .sagittarius: return .fire
        case .taurus, .virgo, .capricorn: return .earth
        case .gemini, .libra, .aquarius: return .air
        case .cancer, .scorpio, .pisces: return .water
        }
    }

    public var rulingPlanet: String {
        switch self {
        case .aries: return "火星"
        case .taurus: return "金星"
        case .gemini: return "水星"
        case .cancer: return "月"
        case .leo: return "太陽"
        case .virgo: return "水星"
        case .libra: return "金星"
        case .scorpio: return "冥王星・火星"
        case .sagittarius: return "木星"
        case .capricorn: return "土星"
        case .aquarius: return "天王星・土星"
        case .pisces: return "海王星・木星"
        }
    }

    public var keywords: String {
        switch self {
        case .aries: return "情熱・開拓・行動力"
        case .taurus: return "安定・五感・豊かさ"
        case .gemini: return "知性・好奇心・コミュニケーション"
        case .cancer: return "共感・家庭・愛情"
        case .leo: return "創造・自己表現・誇り"
        case .virgo: return "繊細・分析・実務力"
        case .libra: return "調和・美意識・パートナーシップ"
        case .scorpio: return "探求・変容・深い絆"
        case .sagittarius: return "自由・哲学・冒険"
        case .capricorn: return "達成・責任感・堅実"
        case .aquarius: return "独創・友愛・未来志向"
        case .pisces: return "直感・癒やし・慈愛"
        }
    }

    public static func from(date: Date, calendar: Calendar = .current) -> ZodiacSign {
        let components = calendar.dateComponents([.month, .day], from: date)
        guard let month = components.month, let day = components.day else {
            return .aries
        }

        switch (month, day) {
        case (3, 21...31), (4, 1...19): return .aries
        case (4, 20...30), (5, 1...20): return .taurus
        case (5, 21...31), (6, 1...21): return .gemini
        case (6, 22...30), (7, 1...22): return .cancer
        case (7, 23...31), (8, 1...22): return .leo
        case (8, 23...31), (9, 1...22): return .virgo
        case (9, 23...30), (10, 1...23): return .libra
        case (10, 24...31), (11, 1...22): return .scorpio
        case (11, 23...30), (12, 1...21): return .sagittarius
        case (12, 22...31), (1, 1...19): return .capricorn
        case (1, 20...31), (2, 1...18): return .aquarius
        case (2, 19...29), (3, 1...20): return .pisces
        default: return .aries
        }
    }
}
