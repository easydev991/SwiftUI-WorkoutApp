//
//  EmptyGrayRoundedRect.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 13.05.2022.
//

import SwiftUI

struct EmptyGrayRoundedRect: View {
    let size: CGSize
    var body: some View {
        Rectangle()
            .frame(width: size.width, height: size.height)
            .foregroundColor(.secondary.opacity(0.5))
            .cornerRadius(8)
    }
}

struct EmptyGrayRoundedRect_Previews: PreviewProvider {
    static var previews: some View {
        EmptyGrayRoundedRect(size: .init(width: 45, height: 45))
    }
}
