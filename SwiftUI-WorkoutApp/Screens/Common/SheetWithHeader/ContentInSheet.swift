import SwiftUI

struct ContentInSheet<Content: View>: View {
    let title: String
    var spacing: CGFloat? = nil
    let content: () -> Content

    var body: some View {
        VStack(spacing: spacing) {
            HeaderForSheet(title: title)
            content()
        }
    }
}

struct ContentInSheet_Previews: PreviewProvider {
    static var previews: some View {
        ContentInSheet(title: "Header") {
            Text("Some content")
        }
    }
}
