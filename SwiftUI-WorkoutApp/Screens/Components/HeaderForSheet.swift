import SwiftUI

struct HeaderForSheet: View {
    let title: String
    let action: () -> Void
    var body: some View {
        HStack {
            Text(title)
                .font(.title3)
                .fontWeight(.medium)
            Spacer()
            Button(action: action) {
                DismissButton()
            }
        }
        .padding()
    }
}

struct HeaderForSheet_Previews: PreviewProvider {
    static var previews: some View {
        HeaderForSheet(title: "Настройки дневника", action: {})
    }
}
