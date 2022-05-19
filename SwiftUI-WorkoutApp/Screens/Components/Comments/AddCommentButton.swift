//
//  AddCommentButton.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 19.05.2022.
//

import SwiftUI

struct AddCommentButton: View {
    @Binding var isCreatingComment: Bool
    var body: some View {
        Button {
            isCreatingComment.toggle()
        } label: {
            Label("Добавить комментарий", systemImage: "plus.message.fill")
                .foregroundColor(.blue)
        }
    }
}

struct AddCommentButton_Previews: PreviewProvider {
    static var previews: some View {
        AddCommentButton(isCreatingComment: .constant(false))
    }
}
