import Foundation

public extension String {
    var withoutHTML: String {
        replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }

    var capitalizingFirstLetter: String {
        prefix(1).capitalized + dropFirst()
    }
}
