//
//  CreateEventView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 24.04.2022.
//

import SwiftUI

struct CreateEventView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CreateEventViewModel
    @State private var eventCreated = false
    @FocusState private var focus: FocusableField?

    var body: some View {
        Form {
            eventNameSection()
            datePickerSection()
            Section("Площадка") {
                sportsGround()
            }
            descriptionTextViewSection()
        }
        .onChange(of: viewModel.isEventCreated) { isSuccess in
            eventCreated = isSuccess
        }
        .alert(Constants.AlertTitle.eventCreated, isPresented: $eventCreated) {
            closeButton()
        }
        .navigationTitle("Мероприятие")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { createEventButton() }
    }
}

private extension CreateEventView {
    enum FocusableField: Hashable {
        case eventName
        case eventDescription
    }

    func eventNameSection() -> some View {
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

    func datePickerSection() -> some View {
        Section("Дата и время") {
            DatePicker("Дата и время", selection: $viewModel.eventDate, in: .now...viewModel.maxDate)
                .labelsHidden()
        }
    }

    func sportsGround() -> AnyView {
        switch viewModel.mode {
        case .regular:
            return AnyView(
                NavigationLink(
                    destination: {
                        Text("Список моих площадок с возможностью выбора по нажатию")
                            .navigationTitle("Выбери площадку")
                            .navigationBarTitleDisplayMode(.inline)
                    }, label: {
                        Text("Выбрать")
                            .blueMediumWeight()
                    }
                )
            )
        case let .selectedSportsGround(ground):
            return AnyView(Text(ground.name))
        }
    }

    func descriptionTextViewSection() -> some View {
        Section("Описание") {
            TextEditor(text: $viewModel.eventDescription)
                .frame(height: 150)
                .focused($focus, equals: .eventDescription)
        }
    }

    func createEventButton() -> some View {
        Button {
            focus = nil
            viewModel.createEventAction()
        } label: {
            Text("Сохранить")
        }
        .disabled(!viewModel.isCreateButtonActive)
    }

    func closeButton() -> some View {
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
        CreateEventView(viewModel: .init(mode: .selectedSportsGround(.mock)))
    }
}
