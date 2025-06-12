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
    ResizableCachedImage(
        url: .init(string: "https://workout.su/uploads/avatars/2019/10/2019-10-07-01-10-08-yow.jpg"),
        didTapImage: { _ in }
    )
    .scaledToFit()
}
#endif
