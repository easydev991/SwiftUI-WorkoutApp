//
//  ProfileImageRectangle.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 17.05.2022.
//

import SwiftUI

struct ProfileImageRectangle: ViewModifier {
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
        modifier(ProfileImageRectangle(size: size))
    }
}
