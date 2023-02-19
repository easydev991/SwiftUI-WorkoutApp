import SafariServices
import SwiftUI
import SWModels

struct SafariVCRepresentable: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context _: Context) -> SFSafariViewController {
        .init(url: url)
    }

    func updateUIViewController(_: SFSafariViewController, context _: Context) {}
}

#if DEBUG
struct SafariVCRepresentable_Previews: PreviewProvider {
    static var previews: some View {
        SafariVCRepresentable(url: Constants.accountCreationURL)
    }
}
#endif
