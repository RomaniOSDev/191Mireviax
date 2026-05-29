import Foundation

enum StepDurationParser {
    static func durationSeconds(from step: String) -> Int? {
        let lowered = step.lowercased()
        let patterns = [
            #"(\d+)\s*-\s*(\d+)\s*min"#,
            #"(\d+)\s*min"#,
            #"(\d+)\s*minutes?"#,
            #"(\d+)\s*sec"#,
            #"(\d+)\s*seconds?"#
        ]
        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern),
                  let match = regex.firstMatch(in: lowered, range: NSRange(lowered.startIndex..., in: lowered)) else {
                continue
            }
            if match.numberOfRanges >= 3,
               let first = Range(match.range(at: 1), in: lowered),
               let second = Range(match.range(at: 2), in: lowered),
               let a = Int(lowered[first]),
               let b = Int(lowered[second]) {
                return ((a + b) / 2) * 60
            }
            if let range = Range(match.range(at: 1), in: lowered), let value = Int(lowered[range]) {
                if pattern.contains("sec") {
                    return value
                }
                return value * 60
            }
        }
        return nil
    }

    static func timersFromRecipe(_ recipe: Recipe) -> [(name: String, seconds: Int)] {
        var results: [(String, Int)] = []
        for (index, step) in recipe.steps.enumerated() {
            if let seconds = durationSeconds(from: step) {
                results.append(("\(recipe.name) — Step \(index + 1)", seconds))
            }
        }
        if results.isEmpty {
            results.append((recipe.name, recipe.cookingTimeMinutes * 60))
        }
        return results
    }
}
