//
//  CreateEventView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 24.04.2022.
//

import SwiftUI

struct CreateEventView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var eventName = ""
    @State private var eventDate = Date()
    @State private var eventDescription = ""
    @State private var alertTitle = "Мероприятие создано!"
    @State private var isEventCreated = false
    @FocusState private var isFocused
    let model: SportsGround

    private var maxDate: Date {
        Calendar.current.date(
            byAdding: .year,
            value: Constants.maxEventFutureYear,
            to: .now
        ) ?? .now
    }
    var body: some View {
        Form {
            eventNameSection()
            datePickerSection()
            sportsGroundNameSection()
            descriptionTextViewSection()
        }
        .navigationTitle("Мероприятие")
        .toolbar {
            createEventButton()
        }
    }
}

private extension CreateEventView {
    func eventNameSection() -> some View {
        Section {
            TextField("Название", text: $eventName)
                .focused($isFocused)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        isFocused.toggle()
                    }
                }
        }
    }

    func datePickerSection() -> some View {
        Section("Дата и время") {
            DatePicker("Дата и время", selection: $eventDate, in: .now...maxDate)
                .labelsHidden()
        }
    }

    func sportsGroundNameSection() -> some View {
        Section("Площадка") {
            Text(model.name)
        }
    }

    func descriptionTextViewSection() -> some View {
        Section("Описание") {
            TextEditor(text: $eventDescription)
                .frame(height: 150)
        }
    }

    func createEventButton() -> some View {
        Button {
#warning("Отправить мероприятие на сервер")
            isFocused.toggle()
            isEventCreated.toggle()
        } label: {
            Text("Сохранить")
        }
        .disabled(eventName.count < 6)
        .alert(alertTitle, isPresented: $isEventCreated) {
            closeButton()
        }
    }

    func closeButton() -> some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            Text("Закрыть")
        }
    }
}

struct CreateEventView_Previews: PreviewProvider {
    static var previews: some View {
        CreateEventView(model: .mock)
    }
}
