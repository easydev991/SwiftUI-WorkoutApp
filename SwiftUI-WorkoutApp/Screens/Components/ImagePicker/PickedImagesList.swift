import SwiftUI

struct PickedImagesList: View {
    @State private var isShowingPicker = false
    @Binding var images: [UIImage]

    var body: some View {
        List {
            ForEach(images, id: \.self) { image in
                HStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 100)
                        .cornerRadius(8)
                    Spacer()
                    Text("Для удаления потяни справа налево")
                }
            }
            .onDelete(perform: deletePhoto)
            Button {
                isShowingPicker.toggle()
            } label: {
                Label("Добавить фотографии", systemImage: "plus.circle.fill")
                    .foregroundColor(.blue)
            }
        }
        .sheet(isPresented: $isShowingPicker) {
            ImagePicker(
                selectedImages: $images,
                showPicker: $isShowingPicker
            )
        }
    }
}

private extension PickedImagesList {
    func deletePhoto(at offsets: IndexSet) {
        if let index = offsets.first {
            images.remove(at: index)
        }
    }
}

struct PickedImagesList_Previews: PreviewProvider {
    static var previews: some View {
        PickedImagesList(images: .constant([]))
            .padding()
    }
}
