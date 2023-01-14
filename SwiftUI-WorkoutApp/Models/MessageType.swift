import Foundation
import UIKit.UIColor

enum MessageType {
    case incoming, sent

    var color: UIColor { self == .incoming ? .systemGreen : .systemBlue }
}
