import ImagePicker
import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient
import SWUtils

/// Экран для создания/изменения мероприятия
struct EventFormScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isNetworkConnected) private var isNetworkConnected
    @EnvironmentObject private var defaults: DefaultsService
    @State private var eventForm: EventForm
    @State private var newImages = [UIImage]()
    @State private var isLoading = false
    @State private var showImagePicker = false
    @State private var saveEventTask: Task<Void, Never>?
    @FocusState private var focus: FocusableField?
    private let oldEventForm: EventForm
    private let mode: Mode
    private var refreshClbk: (() -> Void)?
    private let maxEventFutureDate = Calendar.current.date(
        byAdding: .year, value: 1, to: .now
    ) ?? .now

    init(mode: Mode, refreshClbk: (() -> Void)? = nil) {
        self.mode = mode
        self.refreshClbk = refreshClbk
        switch mode {
        case let .editExisting(event):
            self.oldEventForm = .init(event)
        case let .createForSelected(parkID, parkName):
            self.oldEventForm = .init(parkID, parkName)
        case .regularCreate:
            self.oldEventForm = .emptyValue
        }
        self._eventForm = .init(initialValue: oldEventForm)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                eventNameSection
                descriptionSection
                parkSection
                datePickerSection
                pickedImagesGrid
                saveButton
            }
            .padding()
        }
        .loadingOverlay(if: isLoading)
        .background(Color.swBackground)
        .onDisappear { saveEventTask?.cancel() }
        .navigationTitle(mode.title)
        .navigationBarTitleDisplayMode(.inline)
        .interactiveDismissDisabled(isLoading)
    }
}

extension EventFormScreen {
    enum Mode {
        /// Для экрана "Мероприятия"
        case regularCreate
        /// Для детальной страницы площадки
        case createForSelected(_ parkID: Int, _ parkName: String)
        /// Для редактирования мероприятия
        case editExisting(EventResponse)

        var eventID: Int? {
            if case let .editExisting(eventResponse) = self {
                eventResponse.id
            } else {
                nil
            }
        }

        var title: LocalizedStringKey {
            switch self {
            case .regularCreate, .createForSelected: "Новое мероприятие"
            case .editExisting: "Мероприятие"
            }
        }
    }
}

private extension EventFormScreen {
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

    var parkSection: some View {
        SectionView(header: "Площадка", mode: .regular) {
            switch mode {
            case .regularCreate, .editExisting:
                NavigationLink(destination: userParksScreen) {
                    ListRowView(
                        leadingContent: .text(eventForm.parkName),
                        trailingContent: .chevron
                    )
                }
                .disabled(!canShowParkPicker)
            case let .createForSelected(_, parkName):
                ListRowView(
                    leadingContent: .text(parkName),
                    trailingContent: .empty
                )
            }
        }
    }

    /// Площадки, где тренируется пользователь
    ///
    /// `canShowParkPicker` проверяет на существование `userID`
    var userParksScreen: some View {
        ParksListScreen(
            mode: .event(
                userID: defaults.mainUserInfo?.id ?? 0,
                didSelectPark: { id, name in
                    eventForm.parkID = id
                    eventForm.parkName = name
                }
            )
        )
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
            selectionLimit: eventForm.imagesLimit,
            processExtraImages: {
                while eventForm.imagesLimit < 0 {
                    newImages.removeLast()
                }
            }
        )
        .onChange(of: newImages) { images in
            eventForm.newMediaFiles = images.toMediaFiles
        }
    }

    var saveButton: some View {
        Button("Сохранить") {
            focus = nil
            isLoading = true
            saveEventTask = Task {
                do {
                    let savedEvent = try await SWClient(with: defaults)
                        .saveEvent(id: mode.eventID, form: eventForm)
                    if savedEvent.id != .zero {
                        refreshClbk?()
                        dismiss()
                    }
                } catch {
                    SWAlert.shared.presentDefaultUIKit(error)
                }
                isLoading = false
            }
        }
        .buttonStyle(SWButtonStyle(mode: .filled, size: .large))
        .padding(.top, 42)
        .disabled(!isFormReady || !isNetworkConnected)
    }

    var isFormReady: Bool {
        switch mode {
        case .regularCreate, .createForSelected: eventForm.isReadyToCreate
        case .editExisting: eventForm.isReadyToUpdate(old: oldEventForm)
        }
    }

    /// Не показываем пикер площадок, если `userID` для основного пользователя отсутствует
    var canShowParkPicker: Bool {
        guard isNetworkConnected, let userInfo = defaults.mainUserInfo else { return false }
        switch mode {
        case .regularCreate:
            return true
        case .editExisting:
            return userInfo.usedParksCount > 1
        case .createForSelected:
            return false
        }
    }
}

#if DEBUG
#Preview {
    EventFormScreen(mode: .regularCreate, refreshClbk: {})
        .environmentObject(DefaultsService())
}
#endif
