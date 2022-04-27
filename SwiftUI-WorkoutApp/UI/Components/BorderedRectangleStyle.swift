//
//  BorderedRectangleStyle.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 27.04.2022.
//

import SwiftUI

struct BorderedRectangleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .frame(height: 48)
            .padding(.horizontal)
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke()
            }
    }
}

extension View {
    func roundedBorderedStyle() -> some View {
        modifier(BorderedRectangleStyle())
    }
}
