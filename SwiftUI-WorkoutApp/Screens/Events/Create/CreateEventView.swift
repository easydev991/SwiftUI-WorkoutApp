//
//  CreateEventView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 24.04.2022.
//

import SwiftUI

struct CreateEventView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var defaults: UserDefaultsService
    @ObservedObject var viewModel: CreateEventViewModel
    @State private var eventCreated = false
    @FocusState private var focus: FocusableField?

    var body: some View {
        Form {
            eventNameSection
            datePickerSection
            Section("Площадка") {
                sportsGround
            }
            descriptionSection
        }
        .onChange(of: viewModel.isEventCreated) { eventCreated = $0 }
        .alert(Constants.Alert.eventCreated, isPresented: $eventCreated) {
            closeButton
        }
        .navigationTitle("Мероприятие")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { createEventButton }
    }
}

private extension CreateEventView {
    enum FocusableField: Hashable {
        case eventName
        case eventDescription
    }

    var eventNameSection: some View {
        Section {
            TextField("Название", text: $viewModel.eventName)
                .focused($focus, equals: .eventName)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        focus = .eventName
                    }
                }
        }
    }

    var datePickerSection: some View {
        Section("Дата и время") {
            DatePicker("Дата и время", selection: $viewModel.eventDate, in: .now...viewModel.maxDate)
                .labelsHidden()
        }
    }

    var sportsGround: AnyView {
        switch viewModel.mode {
        case .regular:
            return AnyView(
                NavigationLink(
                    destination: {
                        SportsGroundListView(mode: .usedBy(userID: defaults.mainUserID))
                            .navigationTitle("Выбери площадку")
                            .navigationBarTitleDisplayMode(.inline)
                    }, label: {
                        Text("Выбрать")
                            .blueMediumWeight()
                    }
                )
            )
        case let .selectedSportsGround(ground):
            return AnyView(Text(ground.name.valueOrEmpty))
        }
    }

    var descriptionSection: some View {
        Section("Описание") {
            TextEditor(text: $viewModel.eventDescription)
                .frame(height: 150)
                .focused($focus, equals: .eventDescription)
        }
    }

    var createEventButton: some View {
        Button {
            focus = nil
            viewModel.createEventAction()
        } label: {
            Text("Сохранить")
        }
        .disabled(!viewModel.isCreateButtonActive)
    }

    var closeButton: some View {
        Button {
            viewModel.eventAlertClosed()
            dismiss()
        } label: {
            TextOk()
        }
    }
}

struct CreateEventView_Previews: PreviewProvider {
    static var previews: some View {
        CreateEventView(viewModel: .init(mode: .selectedSportsGround(.emptyValue)))
    }
}
