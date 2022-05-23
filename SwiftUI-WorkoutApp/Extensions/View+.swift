//
//  View+.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 23.05.2022.
//

import SwiftUI

extension View {
    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}
