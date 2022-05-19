//
//  PhotosCollection.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 19.05.2022.
//

import SwiftUI

struct PhotosCollection: View {
    let items: [Photo]

    var body: some View {
        Section("Фотографии") {
            LazyVGrid(
                columns: .init(
                    repeating: .init(.flexible(maximum: 150)),
                    count: Columns(items.count).rawValue
                )
            ) {
                ForEach(items) {
                    CacheAsyncImage(url: $0.imageURL) { phase in
                        switch phase {
                        case let .success(image):
                            image
                                .resizable()
                                .scaledToFill()
                                .cornerRadius(8)
                        case let .failure(error):
                            RoundedDefaultImage(size: .init(width: 100, height: 100))
                                .overlay {
                                    Text(error.localizedDescription)
                                        .background(.white)
                                        .foregroundColor(.black)
                                        .cornerRadius(8)
                                        .multilineTextAlignment(.center)
                                }
                        default:
                            ProgressView()
                        }
                    }
                }
            }
        }
    }
}

private extension PhotosCollection {
    enum Columns: Int {
        case one = 1, two, three
        init(_ photosCount: Int) {
            switch photosCount {
            case 1: self = .one
            case 2: self = .two
            default: self = .three
            }
        }
    }
}

struct PhotosCollection_Previews: PreviewProvider {
    static var previews: some View {
        PhotosCollection(items: [.mock, .mock, .mock])
    }
}
