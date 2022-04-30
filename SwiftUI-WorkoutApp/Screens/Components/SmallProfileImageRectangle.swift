//
//  SmallProfileImageRectangle.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 24.04.2022.
//

import SwiftUI

struct SmallProfileImageRectangle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scaledToFill()
            .frame(width: 36, height: 36)
            .cornerRadius(8)
    }
}

extension View {
    func smallProfileImageRect() -> some View {
        modifier(SmallProfileImageRectangle())
    }
}
