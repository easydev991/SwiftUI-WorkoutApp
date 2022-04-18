//
//  LabelWithCheckmark.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 18.04.2022.
//

import SwiftUI

struct TextWithCheckmark: View {
    let title: String
    let showMark: Bool

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Image(systemName: "checkmark")
                .opacity(showMark ? 1 : .zero)
        }
    }
}

struct LabelWithCheckmark_Previews: PreviewProvider {
    static var previews: some View {
        TextWithCheckmark(title: "Text", showMark: true)
    }
}
