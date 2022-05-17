//
//  SpecificSizeImageRectangle.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 24.04.2022.
//

import SwiftUI

struct SpecificSizeImageRectangle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .aspectRatio(contentMode: .fit)
            .cornerRadius(8)
            .frame(maxWidth: .infinity, maxHeight: 200)
    }
}

extension View {
    func applyProfileImageStyle() -> some View {
        modifier(SpecificSizeImageRectangle())
    }
}
