import CachedAsyncImage991
import SwiftUI

public struct ResizableCachedImage: View {
    private let url: URL?
    private let didTapImage: ((UIImage) -> Void)
    
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
            Image.defaultWorkoutImage
                .resizable()
        }
    }
}

#if DEBUG
struct ResizableCachedImage_Previews: PreviewProvider {
    static var previews: some View {
        ResizableCachedImage(url: nil, didTapImage: { _ in })
    }
}
#endif
