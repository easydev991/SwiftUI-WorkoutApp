//
//  CreateEventView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 24.04.2022.
//

import SwiftUI

struct CreateEventView: View {
    @Environment(\.presentationMode) var presentationMode
    @FocusState private var focus: FocusableField?
    @ObservedObject var viewModel: CreateEventViewModel

    var body: some View {
        Form {
            eventNameSection()
            datePickerSection()
            sportsGroundNameSection()
            descriptionTextViewSection()
        }
        .onChange(of: viewModel.isEventCreated) { _ in
            presentationMode.wrappedValue.dismiss()
        }
        .navigationTitle("Мероприятие")
        .toolbar {
            createEventButton()
        }
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

    func sportsGroundNameSection() -> some View {
        Section("Площадка") {
            Text(viewModel.ground.name)
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
}

struct CreateEventView_Previews: PreviewProvider {
    static var previews: some View {
        CreateEventView(viewModel: .init(with: .mock))
    }
}
