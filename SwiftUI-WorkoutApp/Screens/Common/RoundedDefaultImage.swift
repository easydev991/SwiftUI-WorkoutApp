import SwiftUI

/// Дефолтная картинка `Workout`
struct RoundedDefaultImage: View {
    let size: CGSize
    var body: some View {
        Image("defaultWorkoutImage")
            .resizable()
            .scaledToFit()
            .cornerRadius(8)
            .frame(width: size.width, height: size.height)
    }
}

#if DEBUG
struct RoundedRectDefaultImage_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RoundedDefaultImage(size: .init(width: 45, height: 45))
            RoundedDefaultImage(size: .init(width: 60, height: 60))
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
