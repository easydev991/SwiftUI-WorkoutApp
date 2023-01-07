import SwiftUI

struct PickedImagesList: View {
    @Binding var images: [UIImage]

    var body: some View {
        List {
            ForEach(Array(zip(images.indices, images)), id: \.0) { index, image in
                HStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 100)
                        .cornerRadius(8)
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Фото № \(index + 1)")
                        Text("Свайпни для удаления")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .onDelete(perform: deletePhoto)
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

#if DEBUG
struct PickedImagesList_Previews: PreviewProvider {
    static var previews: some View {
        PickedImagesList(
            images: .constant([
                .init(named: "defaultWorkoutImage")!,
                .init(named: "defaultWorkoutImage")!
            ])
        )
    }
}
#endif
