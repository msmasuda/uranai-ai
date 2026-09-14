import Foundation

public struct FortuneParser {
    public static func parse(
        text: String,
        profile: UserProfile,
        conversationId: UUID?,
        toolEvents: [String] = []
    ) -> FortuneResult {
        let headline = extractHeadline(from: text) ?? "\(profile.zodiacSign.rawValue)の運気が輝く星巡りの一日"
        let overallScore = extractScore(from: text) ?? 85

        let luckyElements = extractLuckyElements(from: text)

        let score = FortuneScore(
            overall: overallScore,
            love: min(100, max(40, overallScore + Int.random(in: -10...5))),
            career: min(100, max(40, overallScore + Int.random(in: -8...8))),
            money: min(100, max(40, overallScore + Int.random(in: -12...6)))
        )

        return FortuneResult(
            conversationId: conversationId,
            createdAt: Date(),
            userName: profile.nickname,
            zodiacSign: profile.zodiacSign,
            category: profile.selectedCategory,
            headline: headline,
            fullReadingText: text,
            score: score,
            luckyElements: luckyElements,
            toolEvents: toolEvents
        )
    }

    private static func extractHeadline(from text: String) -> String? {
        let lines = text.components(separatedBy: .newlines)
        for (index, line) in lines.enumerated() {
            if line.contains("【星の神託】") {
                let trimmed = line.replacingOccurrences(of: "【星の神託】", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    return trimmed.replacingOccurrences(of: "「", with: "").replacingOccurrences(of: "」", with: "")
                }
                if index + 1 < lines.count {
                    let nextLine = lines[index + 1].trimmingCharacters(in: .whitespacesAndNewlines)
                    if !nextLine.isEmpty && !nextLine.hasPrefix("【") {
                        return nextLine.replacingOccurrences(of: "「", with: "").replacingOccurrences(of: "」", with: "")
                    }
                }
            }
        }
        return nil
    }

    private static func extractScore(from text: String) -> Int? {
        // Look for patterns like 【総合運気指数】85 / 100 or 85点 or 85%
        let pattern = #"【総合運気指数】[^\d]*(\d{1,3})"#
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let nsString = text as NSString
            let results = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
            if let first = results.first, first.numberOfRanges > 1 {
                let scoreString = nsString.substring(with: first.range(at: 1))
                if let val = Int(scoreString), val >= 0 && val <= 100 {
                    return val
                }
            }
        }
        return nil
    }

    private static func extractLuckyElements(from text: String) -> LuckyElements {
        var color = "ラピスラズリブルー"
        var item = "星モチーフの小物"
        var number = "7"
        var action = "深呼吸をして空を見上げる"

        let lines = text.components(separatedBy: .newlines)
        for line in lines {
            let clean = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if clean.contains("ラッキーカラー") {
                if let val = clean.components(separatedBy: "：").last ?? clean.components(separatedBy: ":").last {
                    let t = val.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !t.isEmpty { color = t }
                }
            } else if clean.contains("ラッキーアイテム") {
                if let val = clean.components(separatedBy: "：").last ?? clean.components(separatedBy: ":").last {
                    let t = val.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !t.isEmpty { item = t }
                }
            } else if clean.contains("ラッキーナンバー") {
                if let val = clean.components(separatedBy: "：").last ?? clean.components(separatedBy: ":").last {
                    let t = val.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !t.isEmpty { number = t }
                }
            } else if clean.contains("ラッキーアクション") {
                if let val = clean.components(separatedBy: "：").last ?? clean.components(separatedBy: ":").last {
                    let t = val.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !t.isEmpty { action = t }
                }
            }
        }

        return LuckyElements(color: color, item: item, number: number, action: action)
    }
}
