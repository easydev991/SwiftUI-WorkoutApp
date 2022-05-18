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
                ZStack {
                    Capsule()
                        .frame(width: 51,height: 31)
                        .foregroundColor(isOn ? .green : .secondary.opacity(0.5))
                    ZStack{
                        Circle()
                            .frame(width: 40, height: 26)
                            .foregroundColor(.white)
                    }
                    .shadow(
                        color: .black.opacity(0.14),
                        radius: 4,
                        x: .zero,
                        y: 2
                    )
                    .offset(x: isOn ? 10 : -10)
                    .animation(.spring(), value: isOn)
                }
            }
        }
    }
}

struct CustomToggle_Previews: PreviewProvider {
    static var previews: some View {
        CustomToggle(isOn: .constant(true), title: "Тренируюсь здесь") {}
            .padding()
    }
}
