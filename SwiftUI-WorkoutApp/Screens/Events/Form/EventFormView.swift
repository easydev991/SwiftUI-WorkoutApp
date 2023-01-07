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
    @State private var showImagePicker = false
    @State private var showGroundPicker = false
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
            saveButton
        }
        .opacity(viewModel.isLoading ? 0.5 : 1)
        .overlay {
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : 0)
        }
        .animation(.easeInOut, value: viewModel.isLoading)
        .disabled(viewModel.isLoading)
        .sheet(isPresented: $showImagePicker) {
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
            TextField("Название мероприятия", text: $viewModel.eventForm.title)
                .focused($focus, equals: .eventName)
        }
    }

    var datePickerSection: some View {
        Section("Дата и время") {
            DatePicker(
                "Дата и время",
                selection: $viewModel.eventForm.date,
                in: .now...Constants.maxEventFutureDate
            )
            .labelsHidden()
        }
    }

    var sportsGroundSection: some View {
        Section("Площадка") {
            switch mode {
            case .regularCreate:
                Button(action: showGroundPickerIfAvailable) {
                    Text(viewModel.eventForm.sportsGround.name ?? "Выбрать")
                        .blueMediumWeight()
                }
            case let .createForSelected(ground):
                Text(ground.name.valueOrEmpty)
            case let .editExisting(event):
                Button(action: showGroundPickerIfAvailable) {
                    Text(event.sportsGround.shortTitle)
                }
            }
        }
        .sheet(isPresented: $showGroundPicker) {
            ContentInSheet(title: "Выбери площадку", spacing: .zero) {
                SportsGroundsListView(
                    for: .event(userID: defaults.mainUserInfo!.userID!),
                    ground: $viewModel.eventForm.sportsGround
                )
            }
        }
    }

    var descriptionSection: some View {
        Section("Описание") {
            TextEditor(text: $viewModel.eventForm.description)
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
            Text(
                viewModel.imagesLimit <= 0
                ? "Больше добавить фото нельзя"
                : "Можно добавить еще \(viewModel.imagesLimit) фото"
            )
        }
    }

    var pickImagesButton: some View {
        AddPhotoButton(
            isAddingPhotos: $showImagePicker,
            focusClbk: { focus = nil }
        )
        .disabled(!viewModel.canAddImages)
    }

    var saveButton: some View {
        Section {
            ButtonInForm("Сохранить", action: saveAction)
                .disabled(
                    !viewModel.isFormReady
                    || viewModel.isLoading
                    || !network.isConnected
                )
        }
    }

    func showGroundPickerIfAvailable() {
        if viewModel.canShowGroundPicker(with: defaults) {
            showGroundPicker.toggle()
        }
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

#if DEBUG
struct CreateEventView_Previews: PreviewProvider {
    static var previews: some View {
        EventFormView(for: .regularCreate, refreshClbk: {})
            .environmentObject(CheckNetworkService())
            .environmentObject(DefaultsService())
    }
}
#endif
