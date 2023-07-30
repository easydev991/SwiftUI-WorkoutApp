import DesignSystem
import ImagePicker
import NetworkStatus
import SwiftUI
import SWModels

/// Экран для создания/изменения мероприятия
struct EventFormView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var network: NetworkStatus
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
        ScrollView {
            VStack(spacing: 0) {
                eventNameSection
                sportsGroundSection
                datePickerSection
                descriptionSection
                pickedImagesGrid
                saveButton
            }
            .padding([.horizontal, .bottom])
        }
        .loadingOverlay(if: viewModel.isLoading)
        .background(Color.swBackground)
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .alert(alertMessage, isPresented: $showErrorAlert) {
            Button("Ok", action: closeAlert)
        }
        .onChange(of: viewModel.isEventSaved, perform: dismiss)
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
        case eventName, eventDescription
    }

    var eventNameSection: some View {
        SectionView(header: "Название", mode: .regular) {
            SWTextField(
                placeholder: "Название мероприятия",
                text: $viewModel.eventForm.title,
                isFocused: focus == .eventName
            )
            .focused($focus, equals: .eventName)
        }
        .padding(.top, 22)
        .padding(.bottom, 16)
    }

    var sportsGroundSection: some View {
        SectionView(header: "Площадка", mode: .regular) {
            switch mode {
            case .regularCreate:
                Button {
                    showGroundPicker.toggle()
                } label: {
                    ListRowView(
                        leadingContent: .text(viewModel.eventForm.sportsGround.name ?? "Выбрать площадку"),
                        trailingContent: .chevron
                    )
                }
                .disabled(
                    !viewModel.canShowGroundPicker(with: defaults, mode: mode)
                    || !network.isConnected
                )
            case let .createForSelected(ground):
                ListRowView(
                    leadingContent: .text(ground.name.valueOrEmpty),
                    trailingContent: .empty
                )
            case let .editExisting(event):
                Button {
                    showGroundPicker.toggle()
                } label: {
                    ListRowView(
                        leadingContent: .text(event.sportsGround.longTitle),
                        trailingContent: .chevron
                    )
                }
                .disabled(
                    !viewModel.canShowGroundPicker(with: defaults, mode: mode)
                    || !network.isConnected
                )
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

    var datePickerSection: some View {
        DatePicker(
            "Дата и время",
            selection: $viewModel.eventForm.date,
            in: .now ... viewModel.maxEventFutureDate
        )
        .padding(.vertical, 22)
    }

    var descriptionSection: some View {
        SectionView(header: "Описание", mode: .regular) {
            SWTextEditor(
                text: $viewModel.eventForm.description,
                placeholder: "Добавьте немного подробностей о предстоящем мероприятии",
                isFocused: focus == .eventDescription,
                height: 104
            )
            .focused($focus, equals: .eventDescription)
        }
    }

    var pickedImagesGrid: some View {
        PickedImagesGrid(
            images: $viewModel.newImages,
            showImagePicker: $showImagePicker,
            selectionLimit: viewModel.imagesLimit,
            processExtraImages: { viewModel.deleteExtraImagesIfNeeded() }
        )
        .padding(.top, 22)
        .padding(.bottom, 42)
    }

    var saveButton: some View {
        Button("Сохранить") {
            focus = nil
            saveEventTask = Task {
                await viewModel.saveEvent(with: defaults)
            }
        }
        .buttonStyle(SWButtonStyle(mode: .filled, size: .large))
        .disabled(
            !viewModel.isFormReady
                || viewModel.isLoading
                || !network.isConnected
        )
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        alertMessage = message
    }

    func closeAlert() {
        viewModel.clearErrorMessage()
    }

    func dismiss(isSuccess: Bool) {
        if isSuccess {
            refreshClbk?()
            dismiss()
        }
    }

    func cancelTask() {
        saveEventTask?.cancel()
    }
}

#if DEBUG
struct CreateEventView_Previews: PreviewProvider {
    static var previews: some View {
        EventFormView(for: .regularCreate, refreshClbk: {})
            .environmentObject(NetworkStatus())
            .environmentObject(DefaultsService())
    }
}
#endif
