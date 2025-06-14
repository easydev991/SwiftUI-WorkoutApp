import UIKit

/// Состояние вьюхи с картинкой
enum CurrentViewState: Equatable {
    case initial
    case loading
    case ready(UIImage)
    case error
    var uiImage: UIImage? {
        if case let .ready(uiImage) = self { uiImage } else { nil }
    }

    var shouldLoad: Bool {
        self != .loading && uiImage == nil
    }
}
