//
//  PersonsListView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 24.04.2022.
//

import SwiftUI

struct PersonsListView: View {
    @EnvironmentObject private var defaults: UserDefaultsService
    @ObservedObject var viewModel: PersonsListViewModel
    @State private var showErrorAlert = false
    @State private var errorTitle = ""

    var body: some View {
        ZStack {
            List(viewModel.persons, id: \.self) { person in
                NavigationLink {
                    PersonProfileView(viewModel: .init(userID: person.userID.valueOrZero))
                        .navigationBarTitleDisplayMode(.inline)
                } label: {
                    PersonRow(model: person)
                }
            }
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : .zero)
        }
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button(action: retryAction) {
                TextTryAgain()
            }
        }
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .task { await askForPersons() }
    }
}

private extension PersonsListView {
    func askForPersons() async {
        await viewModel.makePersons(defaults: defaults)
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        errorTitle = message
    }

    func retryAction() {
        Task { await askForPersons() }
    }
}

struct PersonsListView_Previews: PreviewProvider {
    static var previews: some View {
        PersonsListView(viewModel: .init(mode: .friends(userID: UserDefaultsService().mainUserID)))
            .environmentObject(UserDefaultsService())
    }
}
