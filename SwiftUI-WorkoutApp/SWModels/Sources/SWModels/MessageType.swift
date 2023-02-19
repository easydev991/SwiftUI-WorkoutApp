import UIKit.UIColor

public enum MessageType {
    case incoming, sent

    public var color: UIColor { self == .incoming ? .systemGray : .systemBlue }
}
