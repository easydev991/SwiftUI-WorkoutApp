import SwiftUI
import ImagePicker

/// Экран для создания/изменения мероприятия
struct EventFormView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var network: CheckNetworkService
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel: EventFormViewModel
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var isShowingPicker = false
    @State private var saveEventTask: Task<Void, Never>?
    @FocusState private var focus: FocusableField?
    private let mode: Mode
    private var refreshClbk: (() -> Void)?

    init(for mode: Mode, refreshClbk: (() -> Void)? = nil) {
        self.mode = mode
        self.refreshClbk = refreshClbk
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
        Form {
            eventNameSection
            datePickerSection
            sportsGroundSection
            descriptionSection
            if !viewModel.newImages.isEmpty {
                pickedImagesList
            }
            if viewModel.imagesLimit > 0 {
                pickImagesButton
            }
        }
        .opacity(viewModel.isLoading ? 0.5 : 1)
        .overlay {
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : .zero)
        }
        .animation(.easeInOut, value: viewModel.isLoading)
        .disabled(viewModel.isLoading)
        .sheet(isPresented: $isShowingPicker) {
            viewModel.deleteExtraImagesIfNeeded()
        } content: {
            ImagePicker(
                pickedImages: $viewModel.newImages,
                selectionLimit: viewModel.imagesLimit,
                compressionQuality: .zero
            )
        }
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .alert(alertMessage, isPresented: $showErrorAlert) {
            Button("Ok", action: closeAlert)
        }
        .onChange(of: viewModel.isSuccess, perform: dismiss)
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
        /// Для редактирования мероприятия
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
                .frame(height: 100)
        }
    }

    var pickedImagesList: some View {
        Section {
            PickedImagesList(images: $viewModel.newImages)
        } header: {
            Text("Фотографии, \(viewModel.newImages.count) шт.")
        } footer: {
            Text(viewModel.imagesLimit <= 0 ? "Больше добавить фото нельзя" : "Можно добавить еще \(viewModel.imagesLimit) фото")
        }
    }

    var pickImagesButton: some View {
        AddPhotoButton(
            isAddingPhotos: $isShowingPicker,
            focusClbk: { focus = nil }
        )
        .disabled(!viewModel.canAddImages)
    }

    var saveButton: some View {
        Button(action: saveAction) {
            Text("Сохранить")
        }
        .disabled(
            !viewModel.eventInfo.isReadyToSend
            || viewModel.isLoading
            || !network.isConnected
        )
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

    func dismiss(isSuccess: Bool) {
        refreshClbk?()
        dismiss()
    }

    func cancelTask() {
        saveEventTask?.cancel()
    }
}

struct CreateEventView_Previews: PreviewProvider {
    static var previews: some View {
        EventFormView(for: .regularCreate, refreshClbk: {})
            .environmentObject(CheckNetworkService())
            .environmentObject(DefaultsService())
    }
}
