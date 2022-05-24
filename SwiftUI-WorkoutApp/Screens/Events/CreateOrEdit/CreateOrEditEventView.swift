import SwiftUI

/// Экран для создания мероприятия
struct CreateOrEditEventView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel: CreateOrEditEventViewModel
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @FocusState private var focus: FocusableField?
    @State private var saveEventTask: Task<Void, Never>?
    private let mode: Mode

    init(for mode: Mode, userInfo: UserResponse) {
        self.mode = mode
        if case let .editExisting(event) = mode {
            _viewModel = StateObject(wrappedValue: .init(with: event, for: userInfo))
        } else {
            _viewModel = StateObject(wrappedValue: .init(with: nil, for: userInfo))
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

extension CreateOrEditEventView {
    enum Mode {
        /// Для экрана "Мероприятия"
        case regularCreate
        /// Для детальной страницы площадки
        case createForSelected(SportsGround)
        case editExisting(EventResponse)
    }
}

private extension CreateOrEditEventView {
    enum FocusableField: Hashable {
        case eventName
        case eventDescription
    }

    var eventNameSection: some View {
        Section {
            TextField("Название", text: $viewModel.eventInfo.formattedTitle)
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
            DatePicker(
                "Дата и время",
                selection: $viewModel.eventDate,
                in: Constants.minEventFutureDate...Constants.maxEventFutureDate
            )
            .labelsHidden()
        }
    }

    var sportsGroundSection: some View {
        Section("Площадка") {
            switch mode {
            case .regularCreate:
                NavigationLink(destination: groundsListView) {
                    Text(viewModel.sportsGround.name ?? "Выбрать")
                        .blueMediumWeight()
                }
            case let .createForSelected(ground):
                Text(ground.name.valueOrEmpty)
            case let .editExisting(event):
                NavigationLink(destination: groundsListView) {
                    Text(event.sportsGround.name.valueOrEmpty)
                }
            }
        }
    }

    var groundsListView: some View {
        SportsGroundsListView(
            for: .event(userID: defaults.mainUserID),
            ground: $viewModel.sportsGround
        )
        .navigationTitle("Выбери площадку")
        .navigationBarTitleDisplayMode(.inline)
    }

    var descriptionSection: some View {
        Section("Описание") {
            TextEditor(text: $viewModel.eventInfo.formattedDescription)
                .frame(height: 150)
                .focused($focus, equals: .eventDescription)
        }
    }

    var saveButton: some View {
        Button(action: saveAction) {
            Text("Сохранить")
        }
        .disabled(!viewModel.canSaveEvent)
    }

    func saveAction() {
        focus = nil
        saveEventTask = Task {
            await viewModel.saveEvent(with: defaults)
        }
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        alertMessage = message
    }

    func closeAlert() {
        viewModel.clearErrorMessage()
    }

    func dismiss(isSaved: Bool) {
        dismiss()
    }

    func cancelTask() {
        saveEventTask?.cancel()
    }
}

struct CreateEventView_Previews: PreviewProvider {
    static var previews: some View {
        CreateOrEditEventView(for: .regularCreate, userInfo: .emptyValue)
            .environmentObject(DefaultsService())
    }
}
