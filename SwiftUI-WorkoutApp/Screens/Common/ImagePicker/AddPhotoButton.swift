import DesignSystem
import SwiftUI

@available(*, deprecated, message: "Use SWButtonStyle instead")
struct AddPhotoButton: View {
    @Binding var isAddingPhotos: Bool
    let focusClbk: () -> Void

    var body: some View {
        Button {
            focusClbk()
            isAddingPhotos.toggle()
        } label: {
            Label("Добавить фото", systemImage: Icons.Button.plus.rawValue)
                .foregroundColor(.blue)
        }
    }
}

#if DEBUG
struct AddPhotoButton_Previews: PreviewProvider {
    static var previews: some View {
        AddPhotoButton(isAddingPhotos: .constant(false), focusClbk: {})
            .previewLayout(.sizeThatFits)
    }
}
#endif
