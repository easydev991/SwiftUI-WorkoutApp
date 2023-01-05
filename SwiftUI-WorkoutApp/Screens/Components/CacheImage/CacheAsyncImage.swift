import SwiftUI

/// Картинка с возможностью кэширования
struct CacheAsyncImage<Content: View>: View {
    @StateObject private var loader: ImageLoader
    private let placeholderSize: CGSize
    private let content: (UIImage) -> Content

    init(
        url: URL?,
        placeholderSize: CGSize = .init(width: 100, height: 100),
        @ViewBuilder content: @escaping (UIImage) -> Content
    ) {
        self.placeholderSize = placeholderSize
        self.content = content
        _loader = StateObject(wrappedValue: .init(url: url, cache: Environment(\.imageCache).wrappedValue))
    }

    var body: some View {
        ZStack {
            if let result = loader.image {
                content(result)
                    .transition(.opacity.combined(with: .scale).combined(with: .move(edge: .bottom)))
            } else {
                RoundedDefaultImage(size: placeholderSize)
            }
        }
        .animation(.easeInOut, value: loader.image)
        .opacity(loader.isLoading ? 0 : 1)
        .onAppear(perform: loader.load)
    }
}
