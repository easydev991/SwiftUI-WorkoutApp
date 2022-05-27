import SwiftUI

struct PickedImagesList: View {
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
                        .font(.callout)
                        .foregroundColor(.secondary)
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

struct PickedImagesList_Previews: PreviewProvider {
    static var previews: some View {
        PickedImagesList(images: .constant([]))
            .padding()
    }
}
