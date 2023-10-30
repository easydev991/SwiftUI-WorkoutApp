import SWDesignSystem
import SwiftUI

struct PickedImageView: View {
    let model: Model
    let height: CGFloat
    let action: (Action) -> Void

    var body: some View {
        switch model {
        case let .image(uiImage):
            Menu {
                Button(action: { action(.showDetailImage(uiImage)) }) {
                    Label("На весь экран", systemImage: Icons.Regular.eye.rawValue)
                }
                Button(role: .destructive, action: { action(.deleteImage) }) {
                    Label("Удалить", systemImage: Icons.Regular.trash.rawValue)
                }
            } label: {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: height)
            }
        case .addImageButton:
            Button(action: { action(.addImage) }) {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .foregroundColor(.swAddPhotoButton)
                    .overlay {
                        Icons.Regular.plus.view
                            .foregroundColor(.swSmallElements)
                    }
                    .scaledToFill()
                    .frame(height: height)
            }
        }
    }
}

extension PickedImageView {
    enum Model {
        case image(UIImage)
        case addImageButton
    }

    enum Action {
        /// Добавить картинку
        case addImage
        /// Удалить картинку
        case deleteImage
        /// Открыть картинку на весь экран
        case showDetailImage(UIImage)
    }
}

#Preview {
    VStack(spacing: 12) {
        PickedImageView(model: .addImageButton, height: 100, action: { _ in })
        PickedImageView(model: .image(.init()), height: 100, action: { _ in })
    }
}
