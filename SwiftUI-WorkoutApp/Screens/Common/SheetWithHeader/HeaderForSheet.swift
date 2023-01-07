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
                Circle()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color("ButtonBackground"))
                    .opacity(0.6)
                    .overlay {
                        Image(systemName: "xmark")
                            .imageScale(.medium)
                            .foregroundColor(Color("ButtonTitle"))
                    }
            }
        }
        .padding()
    }
}

#if DEBUG
struct HeaderForSheet_Previews: PreviewProvider {
    static var previews: some View {
        HeaderForSheet(title: "Настройки дневника")
            .previewLayout(.sizeThatFits)
    }
}
#endif
