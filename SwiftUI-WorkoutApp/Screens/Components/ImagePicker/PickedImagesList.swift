import SwiftUI

struct PickedImagesList: View {
    @State private var isShowingPicker = false
    @State private var images = [UIImage]()

    var body: some View {
        List {
            ForEach(images, id: \.self) { image in
                HStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .background(Color.secondary.opacity(0.5))
                        .cornerRadius(8)
                    Spacer()
                    Button(role: .destructive, action: deleteAction) {
                        Image(systemName: "trash")
                            .font(.title2)
                    }
                }
            }
            Button {
                isShowingPicker.toggle()
            } label: {
                Label("Добавить фотограцию", systemImage: "plus.circle.fill")
                    .foregroundColor(.blue)
            }
        }
        .sheet(isPresented: $isShowingPicker) {
            ImagePicker(selectedImages: $images)
        }
    }
}

private extension PickedImagesList {
    func deleteAction() {

    }
}

struct PickedImagesList_Previews: PreviewProvider {
    static var previews: some View {
        PickedImagesList()
            .padding()
    }
}
