import Foundation

enum IngredientScaler {
    static func scaled(_ ingredient: String, multiplier: Double) -> String {
        guard multiplier != 1 else { return ingredient }
        let pattern = #"^(\d+(?:\.\d+)?)\s*(.*)$"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: ingredient, range: NSRange(ingredient.startIndex..., in: ingredient)),
              let numberRange = Range(match.range(at: 1), in: ingredient),
              let value = Double(ingredient[numberRange]) else {
            if multiplier == 2 {
                return "\(ingredient) ×2"
            }
            if multiplier == 0.5 {
                return "\(ingredient) (half)"
            }
            return ingredient
        }
        let suffixRange = Range(match.range(at: 2), in: ingredient) ?? ingredient.endIndex..<ingredient.endIndex
        let suffix = String(ingredient[suffixRange]).trimmingCharacters(in: .whitespaces)
        let scaled = value * multiplier
        let formatted = scaled.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", scaled)
            : String(format: "%.1f", scaled)
        if suffix.isEmpty {
            return formatted
        }
        return "\(formatted) \(suffix)"
    }
}
