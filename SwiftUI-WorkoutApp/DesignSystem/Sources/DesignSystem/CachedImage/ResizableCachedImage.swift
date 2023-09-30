import CachedAsyncImage991
import SwiftUI

public struct ResizableCachedImage: View {
    private let url: URL?
    private let didTapImage: (UIImage) -> Void

    public init(
        url: URL?,
        didTapImage: @escaping ((UIImage) -> Void)
    ) {
        self.url = url
        self.didTapImage = didTapImage
    }

    public var body: some View {
        CachedAsyncImage991(url: url) { uiImage in
            Button {
                didTapImage(uiImage)
            } label: {
                Image(uiImage: uiImage)
                    .resizable()
            }
        } placeholder: {
            Image.defaultWorkout
                .resizable()
        }
    }
}

#if DEBUG
#Preview {
    ResizableCachedImage(url: nil, didTapImage: { _ in })
}
#endif
