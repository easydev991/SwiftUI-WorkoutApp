import Foundation

public extension String {
    var withoutHTML: String {
        self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }

    var capitalizingFirstLetter: String {
        prefix(1).capitalized + dropFirst()
    }
}
