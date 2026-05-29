import Foundation
import UIKit

enum AppLinks {
    case privacyPolicy
    case termsOfUse

    var urlString: String {
        switch self {
        case .privacyPolicy:
            return "https://mireviax191.site/privacy/214"
        case .termsOfUse:
            return "https://mireviax191.site/terms/214"
        }
    }

    var url: URL? {
        URL(string: urlString)
    }

    func open() {
        guard let url else { return }
        UIApplication.shared.open(url)
    }
}
