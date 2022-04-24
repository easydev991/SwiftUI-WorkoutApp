//
//  CreateCommentView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 23.04.2022.
//

import SwiftUI

struct CreateCommentView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var commentText = ""
    @State private var alertTitle = "Комментарий отправлен!"
    @State private var isCommentSent = false
    @FocusState private var isFocused

    var body: some View {
        VStack(spacing: 24) {
            textView()
            Spacer()
        }
        .padding()
        .navigationTitle("Комментарий")
        .toolbar {
            sendButton()
        }
    }
}

private extension CreateCommentView {
    func textView() -> some View {
        TextEditor(text: $commentText)
            .frame(height: 200)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.gray.opacity(0.5), lineWidth: 2)
            )
            .focused($isFocused)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isFocused.toggle()
                }
            }
    }

    func sendButton() -> some View {
        Button {
#warning("Отправить комментарий на сервер")
            isFocused.toggle()
            isCommentSent.toggle()
        } label: {
            Text("Отправить")
        }
        .disabled(commentText.count < 6)
        .alert(alertTitle, isPresented: $isCommentSent) {
            closeButton()
        }
    }

    func closeButton() -> some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            Text("Закрыть")
        }
    }
}

struct CreateCommentView_Previews: PreviewProvider {
    static var previews: some View {
        CreateCommentView()
    }
}
