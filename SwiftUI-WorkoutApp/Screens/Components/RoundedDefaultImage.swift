import SwiftUI

/// Дефолтная картинка `Workout`
struct RoundedDefaultImage: View {
    let size: CGSize
    var body: some View {
        Image("defaultWorkoutImage")
            .resizable()
            .scaledToFit()
            .frame(width: size.width, height: size.height)
            .cornerRadius(8)
    }
}

struct RoundedRectDefaultImage_Previews: PreviewProvider {
    static var previews: some View {
        RoundedDefaultImage(size: .init(width: 45, height: 45))
    }
}
