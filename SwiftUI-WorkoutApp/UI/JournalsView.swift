//
//  JournalsView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

struct JournalsView: View {
    var body: some View {
        NavigationView {
            Text("Дневники")
                .navigationTitle("Дневники")
        }
    }
}

struct JournalsView_Previews: PreviewProvider {
    static var previews: some View {
        JournalsView()
    }
}
