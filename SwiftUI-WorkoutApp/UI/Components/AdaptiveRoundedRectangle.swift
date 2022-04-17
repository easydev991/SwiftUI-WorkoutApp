//
//  AdaptiveRoundedRectangle.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

struct AdaptiveRoundedRectangle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .foregroundColor(Color("ButtonTitle"))
            .font(.headline)
            .background(Color("ButtonBackground").cornerRadius(8))
    }
}

extension View {
    func roundedRectangleStyle() -> some View {
        modifier(AdaptiveRoundedRectangle())
    }
}
