//
//  SportsGroundListView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 13.05.2022.
//

import SwiftUI

struct SportsGroundListView: View {
    @EnvironmentObject private var defaults: UserDefaultsService
    @StateObject private var viewModel = SportsGroundListViewModel()
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    let userID: Int

    var body: some View {
        ZStack {
            List(viewModel.list) { ground in
                NavigationLink {
                    SportsGroundView(model: .init(groundID: ground.id))
                } label: {
                    SportsGroundViewCell(model: ground)
                }
            }
            .disabled(viewModel.isLoading)
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : .zero)
        }
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button(action: closeAlert) { TextOk() }
        }
        .task { await askForGrounds() }
        .refreshable { await askForGrounds(refresh: true) }
        .navigationTitle("Где тренируется")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension SportsGroundListView {
    func askForGrounds(refresh: Bool = false) async {
        await viewModel.makeSportsGroundsForUser(userID, refresh: refresh, with: defaults)
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        errorTitle = message
    }

    func closeAlert() {
        viewModel.clearErrorMessage()
    }
}

struct SportsGroundListView_Previews: PreviewProvider {
    static var previews: some View {
        SportsGroundListView(userID: UserDefaultsService().mainUserID)
            .environmentObject(UserDefaultsService())
    }
}
