//
//  RoundedDefaultImage.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 13.05.2022.
//

import SwiftUI

struct RoundedDefaultImage: View {
    let size: CGSize
    var body: some View {
        Image("defaultWorkoutImage")
            .resizable()
            .frame(width: size.width, height: size.height)
            .cornerRadius(8)
    }
}

struct RoundedRectDefaultImage_Previews: PreviewProvider {
    static var previews: some View {
        RoundedDefaultImage(size: .init(width: 45, height: 45))
    }
}
