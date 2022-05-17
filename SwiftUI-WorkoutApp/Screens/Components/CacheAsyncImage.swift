//
//  CacheAsyncImage.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 08.05.2022.
//

import SwiftUI

/// Thanks to https://github.com/pitt500/Pokedex
struct CacheAsyncImage<Content>: View where Content: View {
    private let url: URL?
    private let scale: CGFloat
    private let dummySize: CGSize
    private let transaction: Transaction
    private let content: (AsyncImagePhase) -> Content

    init(
        url: URL?,
        scale: CGFloat = 1.0,
        dummySize: CGSize = .init(width: 36, height: 36),
        transaction: Transaction = .init(animation: .easeIn),
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ) {
        self.url = url
        self.scale = scale
        self.dummySize = dummySize
        self.transaction = transaction
        self.content = content
    }

    var body: some View {
        if let cached = ImageCache[url] {
#if DEBUG
            let _ = print("картинка из кэша: \((url?.absoluteString).valueOrEmpty)")
#endif
            content(.success(cached))
        } else if let url = url, !url.absoluteString.contains("avatar_default") {
#if DEBUG
            let _ = print("запросили картинку: \(url)")
#endif
            AsyncImage(url: url, scale: scale, transaction: transaction, content: cacheAndRender)
        } else {
            RoundedRectDefaultImage(size: dummySize)
        }
    }

    func cacheAndRender(phase: AsyncImagePhase) -> some View {
        if let url = url, case let .success(image) = phase {
            ImageCache[url] = image
        }
        return content(phase)
    }
}

struct CacheAsyncImage_Previews: PreviewProvider {
    static var previews: some View {
        CacheAsyncImage(
            url: .init(string: "https://workout.su/uploads/avatars/1442580670.jpg")
        ) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .applySpecificSize(.init(width: 36, height: 36))
            case .failure(let error):
                Text(error.localizedDescription)
            @unknown default:
                ProgressView()
            }
        }
    }
}

fileprivate class ImageCache {
    static private var cache = [URL: Image]()

    static subscript(url: URL?) -> Image? {
        get {
            guard let url = url else { return nil }
            return ImageCache.cache[url]
        }
        set {
            guard let url = url else { return }
            ImageCache.cache[url] = newValue
        }
    }
}
