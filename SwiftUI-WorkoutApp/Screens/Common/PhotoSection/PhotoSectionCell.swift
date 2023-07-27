import DesignSystem
import NetworkStatus
import SwiftUI
import SWModels

struct PhotoSectionCell: View {
    let photo: Photo
    let onTapClbk: (UIImage, Int) -> Void

    var body: some View {
        ResizableCachedImage(
            url: photo.imageURL,
            didTapImage: { uiImage in
                onTapClbk(uiImage, photo.id)
            }
        )
        .scaledToFill()
    }
}

#if DEBUG
struct PhotoSectionCell_Previews: PreviewProvider {
    static var previews: some View {
        PhotoSectionCell(
            photo: .preview,
            onTapClbk: { _, _ in }
        )
        .previewLayout(.sizeThatFits)
    }
}
#endif
