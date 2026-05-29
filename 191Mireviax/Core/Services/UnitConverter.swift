import Foundation

enum UnitConverter {
    static func displayQuantity(_ quantity: String, system: MeasurementSystem) -> String {
        guard system == .imperial else { return quantity }
        var result = quantity
        let replacements: [(String, String)] = [
            (" g", " oz"),
            (" kg", " lb"),
            (" L", " qt"),
            (" ml", " fl oz"),
            (" cm", " in")
        ]
        for (from, to) in replacements {
            if result.localizedCaseInsensitiveContains(from.trimmingCharacters(in: .whitespaces)) {
                result = result.replacingOccurrences(of: from, with: to, options: .caseInsensitive)
            }
        }
        return result
    }
}
