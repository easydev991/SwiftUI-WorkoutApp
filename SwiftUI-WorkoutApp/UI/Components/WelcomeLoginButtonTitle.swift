//
//  WelcomeLoginButtonTitle.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

struct WelcomeLoginButtonTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: 250, height: 48)
            .foregroundColor(.black)
            .font(.headline)
            .background(Color.white.cornerRadius(8))
    }
}

extension View {
    func welcomeLoginButtonTitle() -> some View {
        modifier(WelcomeLoginButtonTitle())
    }
}
