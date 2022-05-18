//
//  CustomToggle.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 18.05.2022.
//

import SwiftUI

struct CustomToggle: View {
    @Binding var isOn: Bool
    let title: String
    let action: () -> Void

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Button(action: action) {
                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                    .font(.title)
            }
        }
        .animation(.easeIn, value: isOn)
    }
}

struct CustomToggle_Previews: PreviewProvider {
    static var previews: some View {
        CustomToggle(isOn: .constant(true), title: "Тренируюсь здесь") {}
            .padding()
    }
}
