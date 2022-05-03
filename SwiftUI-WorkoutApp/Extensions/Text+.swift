//
//  Text+.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 03.05.2022.
//

import SwiftUI

extension Text {
    func blueMediumWeight() -> Text {
        self
            .fontWeight(.medium)
            .foregroundColor(.blue)
    }
}
struct BlueMediumWeightText: View {
    var body: some View {
        Text("Hello, World!")
            .blueMediumWeight()
    }
}

struct BlueMediumWeightText_Previews: PreviewProvider {
    static var previews: some View {
        BlueMediumWeightText()
    }
}
