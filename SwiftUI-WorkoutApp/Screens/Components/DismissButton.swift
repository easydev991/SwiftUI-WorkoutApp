import SwiftUI

struct DismissButton: View {
    var body: some View {
        ZStack {
            Circle()
                .frame(width: 30, height: 30)
                .foregroundColor(Color("ButtonBackground"))
                .opacity(0.6)
            Image(systemName: "xmark")
                .imageScale(.medium)
                .foregroundColor(Color("ButtonTitle"))
        }
    }
}

struct DismissButton_Previews: PreviewProvider {
    static var previews: some View {
        DismissButton()
    }
}
