import NetworkStatus
import PDFKit
import SwiftUI

struct ImageDetailView: UIViewRepresentable {
    let image: UIImage

    func makeUIView(context _: Context) -> PDFView {
        let view = PDFView()
        view.document = PDFDocument()
        guard let page = PDFPage(image: image) else { return view }
        view.document?.insert(page, at: 0)
        view.autoScales = true
        view.backgroundColor = .init(.swBackground)
        return view
    }

    func updateUIView(_: PDFView, context _: Context) {}
}

#if DEBUG
#Preview {
    ImageDetailView(image: .init(systemName: "book")!)
}
#endif
