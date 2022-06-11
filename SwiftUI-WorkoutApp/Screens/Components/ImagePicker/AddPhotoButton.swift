import SwiftUI

struct AddPhotoButton: View {
    @Binding var isAddingPhotos: Bool
    let focusClbk: () -> Void

    var body: some View {
        Button {
            focusClbk()
            isAddingPhotos.toggle()
        } label: {
            Label("Добавить фотографию", systemImage: "plus.circle.fill")
                .foregroundColor(.blue)
        }
    }
}

struct AddPhotoButton_Previews: PreviewProvider {
    static var previews: some View {
        AddPhotoButton(isAddingPhotos: .constant(false), focusClbk: {})
            .previewLayout(.sizeThatFits)
    }
}
