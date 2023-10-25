import ImagePicker
import NetworkStatus
import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient

/// Экран для создания/изменения мероприятия
struct EventFormView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var network: NetworkStatus
    @EnvironmentObject private var defaults: DefaultsService
    @State private var eventForm: EventForm
    @State private var newImages = [UIImage]()
    @State private var isLoading = false
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var showImagePicker = false
    @State private var showGroundPicker = false
    @State private var saveEventTask: Task<Void, Never>?
    @FocusState private var focus: FocusableField?
    private let oldEventForm: EventForm
    private let mode: Mode
    private var refreshClbk: (() -> Void)?
    private let maxEventFutureDate = Calendar.current.date(
        byAdding: .year, value: 1, to: .now
    ) ?? .now

    init(for mode: Mode, refreshClbk: (() -> Void)? = nil) {
        self.mode = mode
        self.refreshClbk = refreshClbk
        switch mode {
        case let .editExisting(event):
            self.oldEventForm = .init(event)
            _eventForm = .init(initialValue: oldEventForm)
        case let .createForSelected(ground):
            self.oldEventForm = .emptyValue
            _eventForm = .init(initialValue: oldEventForm)
            eventForm.sportsGround = ground
        case .regularCreate:
            self.oldEventForm = .init(nil)
            _eventForm = .init(initialValue: oldEventForm)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                eventNameSection
                descriptionSection
                sportsGroundSection
                datePickerSection
                pickedImagesGrid
                saveButton
            }
            .padding()
        }
        .loadingOverlay(if: isLoading)
        .background(Color.swBackground)
        .alert(alertMessage, isPresented: $showErrorAlert) {
            Button("Ok") { alertMessage = "" }
        }
        .onDisappear { saveEventTask?.cancel() }
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

        var eventID: Int? {
            if case let .editExisting(eventResponse) = self {
                eventResponse.id
            } else {
                nil
            }
        }
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
                text: $eventForm.title,
                isFocused: focus == .eventName
            )
            .focused($focus, equals: .eventName)
        }
    }

    var sportsGroundSection: some View {
        SectionView(header: "Площадка", mode: .regular) {
            switch mode {
            case .regularCreate:
                Button { showGroundPicker = true } label: {
                    ListRowView(
                        leadingContent: .text(eventForm.sportsGround.name ?? "Выбрать площадку"),
                        trailingContent: .chevron
                    )
                }
                .disabled(!canShowGroundPicker)
            case let .createForSelected(ground):
                ListRowView(
                    leadingContent: .text(ground.name ?? ""),
                    trailingContent: .empty
                )
            case let .editExisting(event):
                Button { showGroundPicker = true } label: {
                    ListRowView(
                        leadingContent: .text(event.sportsGround.longTitle),
                        trailingContent: .chevron
                    )
                }
                .disabled(!canShowGroundPicker)
            }
        }
        .sheet(isPresented: $showGroundPicker) {
            ContentInSheet(title: "Выбери площадку", spacing: 0) {
                SportsGroundsListView(
                    // `canShowGroundPicker` проверяет на существование `userID`
                    // поэтому тут смело делаем force unwrap
                    for: .event(userID: defaults.mainUserInfo!.userID!),
                    ground: $eventForm.sportsGround
                )
            }
        }
    }

    var datePickerSection: some View {
        VStack(spacing: 16) {
            SWDivider()
            DatePicker(
                "Дата и время",
                selection: $eventForm.date,
                in: .now ... maxEventFutureDate
            )
            SWDivider()
        }
        .padding(.bottom, 10)
    }

    var descriptionSection: some View {
        SectionView(header: "Описание", mode: .regular) {
            SWTextEditor(
                text: $eventForm.description,
                placeholder: "Добавьте немного подробностей о предстоящем мероприятии",
                isFocused: focus == .eventDescription,
                height: 104
            )
            .focused($focus, equals: .eventDescription)
        }
    }

    var pickedImagesGrid: some View {
        PickedImagesGrid(
            images: $newImages,
            showImagePicker: $showImagePicker,
            selectionLimit: imagesLimit,
            processExtraImages: {
                while imagesLimit < 0 {
                    newImages.removeLast()
                }
            }
        )
    }

    var saveButton: some View {
        Button("Сохранить") {
            focus = nil
            isLoading = true
            saveEventTask = Task {
                eventForm.newMediaFiles = newImages.toMediaFiles
                do {
                    let savedEvent = try await SWClient(with: defaults)
                        .saveEvent(id: mode.eventID, form: eventForm)
                    if savedEvent.id != .zero {
                        refreshClbk?()
                        dismiss()
                    }
                } catch {
                    setupErrorAlert(with: ErrorFilter.message(from: error))
                }
                isLoading = false
            }
        }
        .buttonStyle(SWButtonStyle(mode: .filled, size: .large))
        .padding(.top, 42)
        .disabled(!isFormReady || !network.isConnected)
    }

    var isFormReady: Bool {
        mode.eventID == nil
            ? eventForm.isReadyToCreate
            : eventForm.isReadyToUpdate(old: oldEventForm) || !newImages.isEmpty
    }

    var imagesLimit: Int {
        mode.eventID == nil
            ? Constants.photosLimit - newImages.count
            : Constants.photosLimit - newImages.count - eventForm.photosCount
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        alertMessage = message
    }

    /// Не показываем пикер площадок, если `userID` для основного пользователя отсутствует
    var canShowGroundPicker: Bool {
        guard network.isConnected,
              let userInfo = defaults.mainUserInfo,
              userInfo.userID != nil
        else { return false }
        switch mode {
        case .regularCreate:
            return true
        case .editExisting:
            return userInfo.usedSportsGroundsCount > 1
        case .createForSelected:
            return false
        }
    }
}

#if DEBUG
#Preview {
    EventFormView(for: .regularCreate, refreshClbk: {})
        .environmentObject(NetworkStatus())
        .environmentObject(DefaultsService())
}
#endif
