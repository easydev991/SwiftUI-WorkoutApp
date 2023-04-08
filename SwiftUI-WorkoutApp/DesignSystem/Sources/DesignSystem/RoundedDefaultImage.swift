import SwiftUI

/// Дефолтная картинка `Workout`
public struct RoundedDefaultImage: View {
    private let size: CGSize
    
    /// Инициализирует `RoundedDefaultImage`
    /// - Parameter size: Размер картинки
    public init(size: CGSize) {
        self.size = size
    }

    public var body: some View {
        Image.defaultWorkoutImage
            .resizable()
            .scaledToFit()
            .frame(width: size.width, height: size.height)
    }
}

#if DEBUG
struct RoundedRectDefaultImage_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            RoundedDefaultImage(size: .init(width: 45, height: 45))
            RoundedDefaultImage(size: .init(width: 60, height: 60))
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
