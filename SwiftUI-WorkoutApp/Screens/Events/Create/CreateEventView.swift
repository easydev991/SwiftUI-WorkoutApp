import SwiftUI

/// Экран для создания мероприятия
struct CreateEventView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = CreateEventViewModel()
    @FocusState private var focus: FocusableField?
    @State private var createEventTask: Task<Void, Never>?
    let mode: Mode

    var body: some View {
        Form {
            eventNameSection
            datePickerSection
            Section("Площадка") {
                sportsGround
            }
            descriptionSection
        }
        .onChange(of: viewModel.isEventCreated, perform: dismiss)
        .onDisappear(perform: cancelTask)
        .toolbar { createEventButton }
        .navigationTitle("Мероприятие")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension CreateEventView {
    enum Mode {
        /// Для экрана "Мероприятия"
        case regular
        /// Для детальной страницы площадки
        case selectedSportsGround(SportsGround)
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
        switch mode {
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
        Button(action: createEvent) {
            Text("Сохранить")
        }
        .disabled(!viewModel.isCreateButtonActive)
    }

    func createEvent() {
        focus = nil
        createEventTask = Task {
            await viewModel.createEventAction(with: defaults)
        }
    }

    func dismiss(isEventCreated: Bool) {
        dismiss()
    }

    func cancelTask() {
        createEventTask?.cancel()
    }
}

struct CreateEventView_Previews: PreviewProvider {
    static var previews: some View {
        CreateEventView(mode: .regular)
    }
}
