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
    let mode: Mode

    var body: some View {
        ZStack {
            List(viewModel.list) { ground in
                NavigationLink {
#warning("TODO: убедиться, что сервер присылает всю инфу о добавленной пользователем площадке в added_areas")
                    SportsGroundView(input: .full(ground))
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
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension SportsGroundListView {
    enum Mode {
        case usedBy(userID: Int)
        case added(list: [SportsGround])
    }
}

private extension SportsGroundListView {
    func askForGrounds(refresh: Bool = false) async {
        await viewModel.makeSportsGroundsFor(mode, refresh: refresh, with: defaults)
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
        SportsGroundListView(mode: .usedBy(userID: UserDefaultsService().mainUserID))
            .environmentObject(UserDefaultsService())
    }
}
