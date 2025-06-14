import OSLog
import SwiftUI

/// Картинка с возможностью кэширования
public struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "CachedAsyncImage",
        category: "View"
    )
    private let loader: ImageLoaderProtocol = ImageLoader()
    private let transition: AnyTransition
    private let placeholder: Placeholder
    private let content: (UIImage) -> Content
    private let url: URL?
    @State private var currentState = CurrentViewState.initial

    /// Инициализатор с `URL`
    /// - Parameters:
    ///   - url: Ссылка на картинку в формате `URL`
    ///   - transition: Переход из одного состояния в другое, по умолчанию `.scale.combined(with: .opacity)`
    ///   - content: Замыкание с готовой картинкой в формате `UIImage`
    ///   - placeholder: Замыкание для настройки вьюхи на случай отсутствия картинки (загрузка/ошибка)
    public init(
        url: URL?,
        transition: AnyTransition = .scale.combined(with: .opacity),
        @ViewBuilder content: @escaping (UIImage) -> Content,
        @ViewBuilder placeholder: () -> Placeholder = { ProgressView() }
    ) {
        self.url = url
        self.transition = transition
        self.content = content
        self.placeholder = placeholder()
    }

    /// Инициализатор со строкой
    /// - Parameters:
    ///   - stringURL: Ссылка на картинку в формате `String`
    ///   - transition: Переход из одного состояния в другое, по умолчанию `.scale.combined(with: .opacity)`
    ///   - content: Замыкание с готовой картинкой в формате `UIImage`
    ///   - placeholder: Замыкание для настройки вьюхи на случай отсутствия картинки (загрузка/ошибка)
    public init(
        stringURL url: String?,
        transition: AnyTransition = .scale.combined(with: .opacity),
        @ViewBuilder content: @escaping (UIImage) -> Content,
        @ViewBuilder placeholder: () -> Placeholder = { ProgressView() }
    ) {
        let realURL: URL? = if let url { URL(string: url) } else { nil }
        self.init(
            url: realURL,
            transition: transition,
            content: content,
            placeholder: placeholder
        )
    }

    private var currentImage: UIImage? {
        if let cached = loader.getCachedImage(for: url) {
            cached
        } else {
            currentState.uiImage
        }
    }

    public var body: some View {
        ZStack {
            if let currentImage {
                content(currentImage)
                    .transition(transition)
            } else {
                placeholder
            }
        }
        .animation(.easeInOut, value: currentState)
        .task { await getImage() }
    }

    private func getImage() async {
        if let cached = loader.getCachedImage(for: url) {
            currentState = .ready(cached)
            return
        }
        guard currentState.shouldLoad else {
            return
        }
        currentState = .loading
        do {
            let image = try await loader.loadImage(for: url)
            currentState = .ready(image)
        } catch {
            logger.error("\(error.localizedDescription)")
            currentState = .error
        }
    }
}
