import SwiftUI

/// Модификатор, добавляющий форму круга и бордюр с цветом `swAccent`
struct BorderedCircleClipshapeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .clipShape(Circle())
            .overlay {
                Circle()
                    .strokeBorder(Color.swAccent, lineWidth: 2)
            }
    }
}

extension View {
    /// Придает вьюшке форму круга с бордюром цвета `swAccent`
    func borderedCircleClipshape() -> some View {
        modifier(BorderedCircleClipshapeModifier())
    }
}

#if DEBUG
struct BorderedCircleClipshapeModifier_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            Image.defaultWorkoutImage
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .borderedCircleClipshape()
            Image.defaultWorkoutImage
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .borderedCircleClipshape()
        }
    }
}
#endif
