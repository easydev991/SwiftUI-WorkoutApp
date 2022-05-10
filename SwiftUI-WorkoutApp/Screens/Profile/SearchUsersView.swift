//
//  SearchUsersView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 10.05.2022.
//

import SwiftUI

struct SearchUsersView: View {
    @EnvironmentObject private var defaults: UserDefaultsService
    @StateObject private var viewModel = SearchUsersViewModel()
    @State private var query = ""
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    @FocusState private var isFocused

    var body: some View {
        ZStack {
            Form {
                Section {
                    TextField("Найти пользователя", text: $query)
                        .onSubmit(search)
                        .submitLabel(.search)
                        .focused($isFocused)
                }
                Section("Результаты поиска") {
                    List(viewModel.users) { user in
                        NavigationLink {
                            UserProfileView(userID: user.id)
                        } label: {
                            UserViewRow(model: user)
                        }
                    }
                }
                .opacity(viewModel.users.isEmpty ? .zero : 1)
            }
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : .zero)
        }
        .alert(Constants.Alert.error, isPresented: $showErrorAlert) {
            Button {} label: { TextOk() }
        } message: { Text(errorTitle) }
        .disabled(viewModel.isLoading)
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .onAppear(perform: showKeyboard)
        .navigationTitle("Поиск пользователей")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension SearchUsersView {
    func search() {
        Task { await viewModel.searchFor(user: query, with: defaults) }
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        errorTitle = message
    }

    func showKeyboard() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isFocused.toggle()
        }
    }
}

struct SearchUsersView_Previews: PreviewProvider {
    static var previews: some View {
        SearchUsersView()
    }
}
