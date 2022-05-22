//
//  SendMessageView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 21.05.2022.
//

import SwiftUI

struct SendMessageView: View {
    @EnvironmentObject private var network: CheckNetworkService
    @FocusState private var isFocused
    @Binding var text: String
    let isLoading: Bool
    let isSendButtonDisabled: Bool
    let sendAction: () -> Void
    @Binding var showErrorAlert: Bool
    @Binding var errorTitle: String
    let dismissError: () -> Void

    var body: some View {
        ZStack {
            VStack(spacing: 32) {
                sendButtonStack
                textView
                Spacer()
            }
            ProgressView()
                .opacity(isLoading ? 1 : .zero)
        }
        .padding()
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button(action: dismissError) { TextOk() }
        }
    }
}

private extension SendMessageView {
    var sendButtonStack: some View {
        HStack {
            Spacer()
            sendButton
        }
    }

    var sendButton: some View {
        Button(action: sendAction) {
            Label("Отправить", systemImage: "paperplane.fill")
        }
        .tint(.blue)
        .buttonStyle(.borderedProminent)
        .disabled(isSendButtonDisabled || !network.isConnected)
    }

    var textView: some View {
        TextEditor(text: $text)
            .frame(height: 200)
            .padding(.horizontal, 8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.gray.opacity(0.5), lineWidth: 1)
            )
            .focused($isFocused)
            .onAppear(perform: showKeyboard)
    }

    func showKeyboard() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isFocused.toggle()
        }
    }
}

struct SendMessageView_Previews: PreviewProvider {
    static var previews: some View {
        SendMessageView(
            text: .constant(""),
            isLoading: false,
            isSendButtonDisabled: false,
            sendAction: {},
            showErrorAlert: .constant(false),
            errorTitle: .constant(""),
            dismissError: {}
        )
        .environmentObject(CheckNetworkService())
    }
}
