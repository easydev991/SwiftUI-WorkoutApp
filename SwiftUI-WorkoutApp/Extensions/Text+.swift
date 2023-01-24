import SwiftUI

extension Text {
    func blueMediumWeight() -> Text {
        fontWeight(.medium)
            .foregroundColor(.blue)
    }
}

#if DEBUG
struct BlueMediumWeightText_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello, World!")
            .blueMediumWeight()
            .previewLayout(.sizeThatFits)
    }
}
#endif
