import SwiftUI

/// Экран для создания/изменения мероприятия
struct EventFormView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel: EventFormViewModel
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @FocusState private var focus: FocusableField?
    @State private var saveEventTask: Task<Void, Never>?
    @Binding private var needRefreshOnSave: Bool
    private let mode: Mode

    init(for mode: Mode, needRefresh: Binding<Bool> = .constant(false)) {
        self.mode = mode
        _needRefreshOnSave = needRefresh
        switch mode {
        case let .editExisting(event):
            _viewModel = StateObject(wrappedValue: .init(with: event))
        case let .createForSelected(ground):
            _viewModel = StateObject(wrappedValue: .init(with: ground))
        case .regularCreate:
            _viewModel = StateObject(wrappedValue: .init())
        }
    }

    var body: some View {
        ZStack {
            Form {
                eventNameSection
                datePickerSection
                sportsGroundSection
                descriptionSection
            }
            .opacity(viewModel.isLoading ? 0.5 : 1)
            .animation(.easeInOut, value: viewModel.isLoading)
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : .zero)
        }
        .disabled(viewModel.isLoading)
        .onChange(of: viewModel.isSuccess, perform: dismiss)
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .alert(alertMessage, isPresented: $showErrorAlert) {
            Button(action: closeAlert) { TextOk() }
        }
        .onDisappear(perform: cancelTask)
        .toolbar { saveButton }
        .navigationTitle("Мероприятие")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension EventFormView {
    enum Mode {
        /// Для экрана "Мероприятия"
        case regularCreate
        /// Для детальной страницы площадки
        case createForSelected(SportsGround)
        case editExisting(EventResponse)
    }
}

private extension EventFormView {
    enum FocusableField: Hashable {
        case eventName
        case eventDescription
    }

    var eventNameSection: some View {
        Section {
            TextField("Название", text: $viewModel.eventInfo.title)
                .focused($focus, equals: .eventName)
        }
    }

    var datePickerSection: some View {
        Section("Дата и время") {
            DatePicker(
                "Дата и время",
                selection: $viewModel.eventInfo.date,
                in: .now...Constants.maxEventFutureDate
            )
            .labelsHidden()
        }
    }

    var sportsGroundSection: some View {
        Section("Площадка") {
            switch mode {
            case .regularCreate:
                NavigationLink(destination: groundsListView) {
                    Text(viewModel.eventInfo.sportsGround.name ?? "Выбрать")
                        .blueMediumWeight()
                }
            case let .createForSelected(ground):
                Text(ground.name.valueOrEmpty)
            case let .editExisting(event):
                NavigationLink(destination: groundsListView) {
                    Text(event.sportsGround.shortTitle)
                }
            }
        }
    }

    var groundsListView: some View {
        SportsGroundsListView(
            for: .event(userID: defaults.mainUserID),
            ground: $viewModel.eventInfo.sportsGround
        )
        .navigationTitle("Выбери площадку")
        .navigationBarTitleDisplayMode(.inline)
    }

    var descriptionSection: some View {
        Section("Описание") {
            TextEditor(text: $viewModel.eventInfo.description)
                .focused($focus, equals: .eventDescription)
                .frame(height: 150)
        }
    }

    var saveButton: some View {
        Button(action: saveAction) {
            Text("Сохранить")
        }
        .disabled(!viewModel.eventInfo.isReadyToSend || viewModel.isLoading)
    }

    func saveAction() {
        focus = nil
        saveEventTask = Task {
            await viewModel.saveEvent(mode: mode, with: defaults)
        }
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        alertMessage = message
    }

    func closeAlert() {
        viewModel.clearErrorMessage()
    }

    func dismiss(isSuccess: Bool) {
        dismiss()
        needRefreshOnSave.toggle()
    }

    func cancelTask() {
        saveEventTask?.cancel()
    }
}

struct CreateEventView_Previews: PreviewProvider {
    static var previews: some View {
        EventFormView(for: .regularCreate, needRefresh: .constant(false))
            .environmentObject(DefaultsService())
    }
}
