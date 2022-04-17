//
//  MessagesView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

struct MessagesView: View {
    var body: some View {
        NavigationView {
            Text("Сообщения")
                .navigationTitle("Сообщения")
        }
    }
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView()
    }
}
