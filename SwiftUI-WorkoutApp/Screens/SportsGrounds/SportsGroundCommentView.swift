//
//  SportsGroundCommentView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 11.05.2022.
//

import SwiftUI

struct SportsGroundCommentView: View {
    @EnvironmentObject private var defaults: UserDefaultsService
    let model: Comment
    let deleteClbk: (Int) -> Void
    let editClbk: (Int, String) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top, spacing: 16) {
                CacheImageView(url: model.user?.avatarURL)
                nameDate
                Spacer()
                menuButton
                .disabled(!isMenuAvailable)
                .opacity(isMenuAvailable ? 1 : .zero)
            }
            Text(.init(model.formattedBody))
                .fixedSize(horizontal: false, vertical: true)
                .tint(.blue)
                .textSelection(.enabled)
        }
    }
}

private extension SportsGroundCommentView {
    var nameDate: some View {
        VStack(alignment: .leading) {
            Text((model.user?.userName).valueOrEmpty)
                .fontWeight(.medium)
            Text(model.formattedDateString)
                .foregroundColor(.secondary)
                .font(.caption)
                .padding(.bottom, 4)
        }
    }

    var isMenuAvailable: Bool {
        (model.user?.userID).valueOrZero == defaults.mainUserID
    }

    var menuButton: some View {
        Menu {
            Button {
                editClbk(model.id, model.formattedBody)
            } label: {
                Label("Изменить", systemImage: "pencil.circle.fill")
            }
            Button(role: .destructive) {
                deleteClbk(model.id)
            } label: {
                Label("Удалить", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis.circle.fill")
                .font(.title2)
                .foregroundColor(.secondary)
        }
    }
}

struct SportsGroundCommentView_Previews: PreviewProvider {
    static var previews: some View {
        SportsGroundCommentView(
            model: .init(id: .zero, body: "Test comment", date: "2013-01-16T03:35:54+04:00", user: .emptyValue),
            deleteClbk: {_ in},
            editClbk: {_,_ in}
        )
        .environmentObject(UserDefaultsService())
        .padding()
    }
}
