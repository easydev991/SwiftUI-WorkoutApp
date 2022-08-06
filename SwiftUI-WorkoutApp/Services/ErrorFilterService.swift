import Foundation

struct ErrorFilterService {
    static func message(from error: Error) -> String {
        (error as NSError).code == -999 ? "" : error.localizedDescription
    }
}
