import PDFKit
import SwiftUI

/// Обертка для картинки, для которой работает зум
struct PDFViewRepresentable: UIViewRepresentable {
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
    PDFViewRepresentable(image: .init(systemName: "book")!)
}
#endif
