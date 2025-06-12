import SwiftUI

/// Дефолтная картинка `Workout`, можно задать размер в инициализаторе
struct DefaultWorkoutImage: View {
    private let size: CGSize

    /// Инициализирует `RoundedDefaultImage`
    /// - Parameter size: Размер картинки
    init(size: CGSize) {
        self.size = size
    }

    var body: some View {
        Image.defaultWorkout
            .resizable()
            .scaledToFit()
            .frame(width: size.width, height: size.height)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 16) {
        DefaultWorkoutImage(size: .init(width: 45, height: 45))
        DefaultWorkoutImage(size: .init(width: 60, height: 60))
    }
}
#endif
