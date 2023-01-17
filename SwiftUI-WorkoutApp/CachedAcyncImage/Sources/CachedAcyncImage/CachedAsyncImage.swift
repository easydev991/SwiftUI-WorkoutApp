import SwiftUI

/// Картинка с возможностью кэширования
public struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    @StateObject private var loader: ImageLoader
    private var placeholder: () -> Placeholder
    private let content: (UIImage) -> Content

    public init(
        url: URL?,
        @ViewBuilder content: @escaping (UIImage) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.content = content
        self.placeholder = placeholder
        _loader = StateObject(wrappedValue: .init(url: url, cache: Environment(\.imageCache).wrappedValue))
    }

    public var body: some View {
        ZStack {
            if let result = loader.image {
                content(result)
                    .transition(.opacity.combined(with: .scale).combined(with: .move(edge: .bottom)))
            } else {
                placeholder()
            }
        }
        .animation(.easeInOut, value: loader.image)
        .opacity(loader.isLoading ? 0 : 1)
        .onAppear(perform: loader.load)
    }
}
