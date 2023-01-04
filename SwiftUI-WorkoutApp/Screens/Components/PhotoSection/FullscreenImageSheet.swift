import SwiftUI

struct FullScreenImageSheet: View {
    let image: UIImage

    var body: some View {
        VStack {
            HeaderForSheet(title: "Фото")
            ImageDetailView(image: image)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scaledToFit()
        }
    }
}

struct FullScreenImageSheet_Previews: PreviewProvider {
    static var previews: some View {
        FullScreenImageSheet(image: .init(named: "defaultWorkoutImage")!)
    }
}
