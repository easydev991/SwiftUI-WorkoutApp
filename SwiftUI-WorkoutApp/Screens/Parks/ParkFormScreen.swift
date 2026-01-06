import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient
import SWUtils

/// Экран с формой для создания/изменения площадки
struct ParkFormScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isNetworkConnected) private var isNetworkConnected
    @Environment(\.updateGeocodingCache) private var updateGeocodingCache
    @EnvironmentObject private var defaults: DefaultsService
    @EnvironmentObject private var parksManager: ParksManager
    @State private var isLoading = false
    @State private var parkForm: ParkForm
    @State private var newImages = [UIImage]()
    @State private var saveParkTask: Task<Void, Never>?
    @FocusState private var isFocused: Bool
    private let oldParkForm: ParkForm
    private let mode: Mode
    private let refreshClbk: (Park) -> Void

    init(_ mode: Mode, refreshClbk: @escaping (Park) -> Void) {
        self.mode = mode
        switch mode {
        case let .createNew(model):
            self.oldParkForm = .init(
                address: model.address,
                latitude: model.coordinate.latitude,
                longitude: model.coordinate.longitude,
                cityId: model.cityId
            )
            _parkForm = .init(initialValue: oldParkForm)
        case let .editExisting(park):
            self.oldParkForm = .init(park)
            _parkForm = .init(initialValue: oldParkForm)
        }
        self.refreshClbk = refreshClbk
    }

    var body: some View {
        scrollView
            .scrollDismissesKeyboard(.immediately)
    }
}

extension ParkFormScreen {
    enum Mode {
        case createNew(NewParkMapModel)
        case editExisting(Park)

        var parkId: Int? {
            switch self {
            case .createNew: nil
            case let .editExisting(park): park.id
            }
        }
    }
}

private extension ParkFormScreen {
    var scrollView: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(spacing: 12) {
                    addressSection
                    typePicker
                    sizePicker
                }
                pickedImagesGrid
                saveButton
            }
            .padding([.horizontal, .bottom])
        }
        .loadingOverlay(if: isLoading)
        .background(Color.swBackground)
        .onDisappear { saveParkTask?.cancel() }
        .task {
            await performGeocodingForNewPark()
        }
        .navigationTitle("Площадка")
        .navigationBarTitleDisplayMode(.inline)
        .interactiveDismissDisabled(isLoading)
    }

    var addressSection: some View {
        SectionView(header: "Адрес", mode: .regular) {
            SWTextField(
                placeholder: "Адрес площадки",
                text: $parkForm.address,
                lineLimit: 3,
                isFocused: isFocused
            )
            .focused($isFocused)
        }
        .padding(.top, 22)
    }

    var typePicker: some View {
        Menu {
            Picker("", selection: $parkForm.typeId) {
                ForEach(ParkGrade.allCases.map(\.rawValue), id: \.self) {
                    Text(ParkGrade(code: $0).description)
                }
            }
        } label: {
            ListRowView(
                leadingContent: .text("Тип площадки"),
                trailingContent: .textWithChevron(parkForm.gradeString)
            )
        }
    }

    var sizePicker: some View {
        Menu {
            Picker("", selection: $parkForm.sizeId) {
                ForEach(ParkSize.allCases.map(\.rawValue), id: \.self) {
                    Text(ParkSize(code: $0).description)
                }
            }
        } label: {
            ListRowView(
                leadingContent: .text("Размер площадки"),
                trailingContent: .textWithChevron(parkForm.sizeString)
            )
        }
    }

    var pickedImagesGrid: some View {
        PickedImagesGrid(
            images: $newImages,
            selectionLimit: parkForm.imagesLimit,
            processExtraImages: {
                while parkForm.imagesLimit < 0 {
                    newImages.removeLast()
                }
            }
        )
        .padding(.top, 22)
        .padding(.bottom, 42)
        .onChange(of: newImages) { images in
            parkForm.newMediaFiles = images.toMediaFiles
        }
    }

    var saveButton: some View {
        Button("Сохранить") {
            guard !SWAlert.shared.presentNoConnection(isNetworkConnected) else { return }
            isFocused = false
            isLoading = true
            saveParkTask = Task {
                do {
                    #if DEBUG
                    let client: ParksClient = Constants.isUITest
                        ? MockSWClient(instantResponse: true)
                        : SWClient(with: defaults.authHelper)
                    #else
                    let client: ParksClient = SWClient(with: defaults.authHelper)
                    #endif
                    let newPark = try await client
                        .savePark(id: mode.parkId, form: parkForm)
                    if newPark.id != 0 {
                        dismiss()
                        refreshClbk(newPark)
                    }
                } catch {
                    SWAlert.shared.presentDefaultUIKit(error)
                }
                isLoading = false
            }
        }
        .buttonStyle(SWButtonStyle(mode: .filled, size: .large))
        .disabled(!isFormReady)
    }

    var isFormReady: Bool {
        mode.parkId == nil
            ? parkForm.isReadyToCreate
            : parkForm.isReadyToUpdate(old: oldParkForm)
    }

    /// Выполняет геокодирование для новой площадки
    func performGeocodingForNewPark() async {
        guard case let .createNew(model) = mode, model.shouldPerformGeocode else {
            return
        }
        isLoading = true
        do {
            let geocodingService = GeocodingService(coordinate: model.coordinate)
            let result = try await geocodingService.makeAddressAndCityId()
            parkForm.address = result.address
            parkForm.cityId = result.cityId
            updateGeocodingCache(result.address, result.cityId, model.coordinate)
        } catch {
            parkForm.cityId = defaults.mainUserCityId
            if parkForm.cityId == nil {
                parksManager.setShowMissingAddressBadge(true)
            }
            SWAlert.shared.presentDefaultUIKit(error)
        }
        isLoading = false
    }
}

#if DEBUG
#Preview("Создание") {
    ParkFormScreen(.createNew(.empty), refreshClbk: { _ in })
        .environmentObject(DefaultsService(authHelper: MockAuthHelper()))
        .environmentObject(ParksManager(authHelper: MockAuthHelper()))
}

#Preview("Редактирование") {
    ParkFormScreen(.editExisting(.preview), refreshClbk: { _ in })
        .environmentObject(DefaultsService(authHelper: MockAuthHelper()))
        .environmentObject(ParksManager(authHelper: MockAuthHelper()))
}
#endif
