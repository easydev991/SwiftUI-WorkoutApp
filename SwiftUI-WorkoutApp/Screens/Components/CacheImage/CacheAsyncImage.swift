import SwiftUI

/// Картинка с возможностью кэширования
struct CacheAsyncImage<Content: View>: View {
    @StateObject private var loader: ImageLoader
    private let dummySize: CGSize
    private let content: (UIImage) -> Content

    init(
        url: URL?,
        dummySize: CGSize = .init(width: 36, height: 36),
        @ViewBuilder content: @escaping (UIImage) -> Content
    ) {
        self.dummySize = dummySize
        self.content = content
        _loader = StateObject(wrappedValue: ImageLoader(url: url, cache: Environment(\.imageCache).wrappedValue))
    }

    var body: some View {
        ZStack {
            if let result = loader.image {
                content(result)
                    .transition(.opacity.combined(with: .scale).combined(with: .move(edge: .bottom)))
            } else {
                RoundedDefaultImage(size: dummySize)
            }
        }
        .animation(.easeInOut, value: loader.image)
        .opacity(loader.isLoading ? .zero : 1)
        .onAppear(perform: loader.load)
    }
}
