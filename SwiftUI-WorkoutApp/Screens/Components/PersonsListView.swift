//
//  PersonsListView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 24.04.2022.
//

import SwiftUI

struct PersonsListView: View {
    @EnvironmentObject private var defaults: UserDefaultsService
    @StateObject var viewModel = PersonsListViewModel()
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    let mode: Mode

    var body: some View {
        ZStack {
            List(viewModel.persons, id: \.self) { person in
                NavigationLink {
                    PersonProfileView(userID: person.userID.valueOrZero)
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

extension PersonsListView {
    enum Mode {
        case friends(userID: Int)
        case sportsGroundVisitors(groundID: Int)
    }
}

private extension PersonsListView {
    func askForPersons() async {
        await viewModel.makeInfo(for: mode, with: defaults)
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
        PersonsListView(mode: .friends(userID: UserDefaultsService().mainUserID))
            .environmentObject(UserDefaultsService())
    }
}
