//
//  SpecificSizeImageRectangle.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 24.04.2022.
//

import SwiftUI

struct SpecificSizeImageRectangle: ViewModifier {
    let size: CGSize

    func body(content: Content) -> some View {
        content
            .scaledToFill()
            .frame(width: size.width, height: size.height)
            .cornerRadius(8)
    }
}

extension View {
    func applySpecificSize(_ size: CGSize) -> some View {
        modifier(SpecificSizeImageRectangle(size: size))
    }
}
