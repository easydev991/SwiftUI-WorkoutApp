//
//  CreateCommentView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 23.04.2022.
//

import SwiftUI

struct CreateCommentView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var commentText = ""
    @State private var isCommentSent = false
    @FocusState private var isFocused

    var body: some View {
        VStack {
            textView
            Spacer()
        }
        .padding()
        .navigationTitle("Комментарий")
        .toolbar { sendButton }
    }
}

private extension CreateCommentView {
    var textView: some View {
        TextEditor(text: $commentText)
            .frame(height: 200)
            .padding(.horizontal, 8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.gray.opacity(0.5), lineWidth: 1)
            )
            .focused($isFocused)
            .onAppear(perform: showKeyboard)
    }

    var sendButton: some View {
        Button {
#warning("TODO: интеграция с сервером")
            // Отправить комментарий на сервер
            isFocused.toggle()
            isCommentSent.toggle()
        } label: {
            Text("Отправить")
        }
        .disabled(commentText.isEmpty)
        .alert(Constants.Alert.commentSent, isPresented: $isCommentSent) {
            Button { dismiss() } label: { TextOk() }
        }
    }

    func showKeyboard() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isFocused.toggle()
        }
    }
}

struct CreateCommentView_Previews: PreviewProvider {
    static var previews: some View {
        CreateCommentView()
    }
}
