import SwiftUI
import PDFKit

struct ImageDetailView: UIViewRepresentable {
    @Environment(\.colorScheme) private var colorScheme
    let image: UIImage

    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.document = PDFDocument()
        guard let page = PDFPage(image: image) else { return view }
        view.document?.insert(page, at: 0)
        view.autoScales = true
        return view
    }

    func updateUIView(_ view: PDFView, context: Context) {
        view.backgroundColor = colorScheme == .dark ? .black : .white
    }
}

#if DEBUG
struct ImageDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ImageDetailView(image: .init(named: "defaultWorkoutImage")!)
    }
}
#endif
