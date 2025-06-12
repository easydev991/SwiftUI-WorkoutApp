import SwiftUI

/// Модификатор, добавляющий бордюр выбранной формы с цветом `swAccent`
struct BorderedClipShapeModifier: ViewModifier {
    let clipShape: ClipShape

    func body(content: Content) -> some View {
        switch clipShape {
        case .roundedRect:
            content
                .clipShape(
                    RoundedRectangle(cornerRadius: 12)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.swAccent, lineWidth: 2)
                }
        case .circle:
            content
                .clipShape(.circle)
                .overlay {
                    Circle()
                        .stroke(Color.swAccent, lineWidth: 2)
                }
        }
    }
}

extension BorderedClipShapeModifier {
    enum ClipShape {
        case roundedRect
        case circle
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 16) {
        Image.defaultWorkout
            .resizable()
            .scaledToFit()
            .frame(width: 80, height: 80)
            .borderedCircleClipShape()
        Image.defaultWorkout
            .resizable()
            .scaledToFit()
            .frame(width: 120, height: 120)
            .borderedRoundedRectClipShape()
    }
}
#endif
