import SwiftUI

/// Модификатор, добавляющий бордюр выбранной формы с цветом `swAccent`
public struct BorderedClipshapeModifier: ViewModifier {
    let clipShape: ClipShape

    public func body(content: Content) -> some View {
        switch clipShape {
        case .roundedRectangle:
            content
                .clipShape(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.swAccent, lineWidth: 2)
                }
        case .circle:
            content
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(Color.swAccent, lineWidth: 2)
                }
        }
    }
}

public extension BorderedClipshapeModifier {
    enum ClipShape {
        case roundedRectangle
        case circle
    }
}

public extension View {
    /// Придает вьюшке форму с бордюром цвета `swAccent`
    func borderedClipshape(
        _ shape: BorderedClipshapeModifier.ClipShape = .circle
    ) -> some View {
        modifier(BorderedClipshapeModifier(clipShape: shape))
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 16) {
        Image.defaultWorkoutImage
            .resizable()
            .scaledToFit()
            .frame(width: 80, height: 80)
            .borderedClipshape(.circle)
        Image.defaultWorkoutImage
            .resizable()
            .scaledToFit()
            .frame(width: 120, height: 120)
            .borderedClipshape(.roundedRectangle)
    }
    .previewLayout(.sizeThatFits)
}
#endif
