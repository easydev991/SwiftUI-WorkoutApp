//
//  ButtonInFormLabel.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 19.04.2022.
//

import SwiftUI

struct ButtonInFormLabel: View {
    let title: String

    var body: some View {
        HStack {
            Spacer()
            Text(title)
                .font(.headline)
            Spacer()
        }
    }
}

struct ButtonInFormLabel_Previews: PreviewProvider {
    static var previews: some View {
        ButtonInFormLabel(title: "Кнопка")
    }
}
