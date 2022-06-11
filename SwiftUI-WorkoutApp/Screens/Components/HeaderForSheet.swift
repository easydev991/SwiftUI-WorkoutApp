import SwiftUI

struct HeaderForSheet: View {
    @Environment(\.dismiss) private var dismiss
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.title3)
                .fontWeight(.medium)
            Spacer()
            Button {
                dismiss()
            } label: {
                DismissButton()
            }
        }
        .padding()
    }
}

struct HeaderForSheet_Previews: PreviewProvider {
    static var previews: some View {
        HeaderForSheet(title: "Настройки дневника")
            .previewLayout(.sizeThatFits)
    }
}
