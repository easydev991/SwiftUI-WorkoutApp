import DesignSystem
import SwiftUI

struct PickedPhotoView: View {
    let model: Model
    
    var body: some View {
        switch model {
        case let .image(image):
            image
                .resizable()
                .scaledToFill()
        case let .addImageButton:
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .foregroundColor(.swAddPhotoButton)
                .overlay {
                    Image(systemName: "plus")
                        .foregroundColor(.swSmallElements)
                }
        }
    }
}

extension PickedPhotoView {
    enum Model {
        case image(Image)
        case addImageButton
    }
}

struct PickedPhotoView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 12) {
            PickedPhotoView(model: .addImageButton)
            PickedPhotoView(model: .image(Image.defaultWorkoutImage))
        }
    }
}
