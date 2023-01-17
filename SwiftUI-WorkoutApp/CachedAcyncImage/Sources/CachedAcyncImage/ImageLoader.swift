import Combine
import UIKit.UIImage

final class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private(set) var isLoading = false
    private var url: URL?
    private var cache: ImageCache?
    private var cancellable: AnyCancellable?
    private let imageProcessingQueue = DispatchQueue(label: "image-processing")

    init(url: URL?, cache: ImageCache? = nil) {
        self.url = url
        self.cache = cache
    }

    deinit { cancel() }

    func load() {
        guard let url = url, !isLoading else { return }

        if let image = cache?[url] {
            self.image = image
            return
        }

        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .handleEvents(
                receiveSubscription: { [weak self] _ in self?.onStart() },
                receiveOutput: { [weak self] in self?.cache($0) },
                receiveCompletion: { [weak self] _ in self?.onFinish() },
                receiveCancel: { [weak self] in self?.onFinish() }
            )
            .subscribe(on: imageProcessingQueue)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.image = $0 }
    }
}

private extension ImageLoader {
    func cancel() { cancellable?.cancel() }

    func onStart() { isLoading = true }

    func onFinish() { isLoading = false }

    func cache(_ image: UIImage?) {
        image.map { cache?[url!] = $0 }
    }
}
