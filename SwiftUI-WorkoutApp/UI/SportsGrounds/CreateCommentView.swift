//
//  CreateCommentView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 23.04.2022.
//

import SwiftUI

struct CreateCommentView: View {
    @State private var commentText = ""

    var body: some View {
        VStack(spacing: 24) {
            TextEditor(text: $commentText)
                .frame(height: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.gray.opacity(0.5), lineWidth: 2)
                )
            Button {
#warning("Отправить комментарий на сервер")
            } label: {
                Text("Отправить")
                    .roundedRectangleStyle()
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Комментарий")
    }
}

struct CreateCommentView_Previews: PreviewProvider {
    static var previews: some View {
        CreateCommentView()
    }
}
