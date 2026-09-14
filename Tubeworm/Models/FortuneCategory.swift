import Foundation

public enum FortuneCategory: String, Codable, CaseIterable, Identifiable, Sendable {
    case general = "総合運"
    case love = "恋愛・パートナー運"
    case career = "仕事・学業運"
    case money = "金運・財運"
    case relationship = "対人関係・交友運"
    case health = "健康・メンタル運"

    public var id: String { rawValue }

    public var icon: String {
        switch self {
        case .general: return "sparkles"
        case .love: return "heart.fill"
        case .career: return "briefcase.fill"
        case .money: return "yensign.circle.fill"
        case .relationship: return "person.2.fill"
        case .health: return "leaf.fill"
        }
    }

    public var promptFocus: String {
        switch self {
        case .general: return "全体の星回り、運気のリズム、今日大切にすべきマインド"
        case .love: return "恋愛運、心の繋がり、出会いやパートナーとの関係の進展"
        case .career: return "仕事の成果、判断力、周囲からの評価、キャリアの好機"
        case .money: return "お金の使い方、投資や買い物、金運の波と豊かさの引き寄せ"
        case .relationship: return "コミュニケーション、友人や同僚との調和、人間関係のコツ"
        case .health: return "心身のリフレッシュ法、エネルギーの使い方、体調管理"
        }
    }
}
