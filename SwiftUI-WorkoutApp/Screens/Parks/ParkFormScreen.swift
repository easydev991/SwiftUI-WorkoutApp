import CoreLocation.CLLocation
import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient
import SWUtils

/// Экран с формой для создания/изменения площадки
struct ParkFormScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isNetworkConnected) private var isNetworkConnected
    @EnvironmentObject private var defaults: DefaultsService
    @State private var isLoading = false
    @State private var parkForm: ParkForm
    @State private var newImages = [UIImage]()
    @State private var saveParkTask: Task<Void, Never>?
    @State private var geocodingTask: Task<Void, Never>?
    @State private var isLoadingAddress = false
    @FocusState private var isFocused: Bool
    private let oldParkForm: ParkForm
    private let mode: Mode
    private let refreshClbk: () -> Void

    init(_ mode: Mode, refreshClbk: @escaping () -> Void) {
        self.mode = mode
        switch mode {
        case let .createNew(model):
            self.oldParkForm = .init(
                address: "", // Будет заполнено через GeocodingService
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
        if #available(iOS 16.0, *) {
            scrollView
                .scrollDismissesKeyboard(.immediately)
        } else {
            scrollView
                .simultaneousGesture(
                    DragGesture().onChanged { _ in
                        isFocused = false
                    }
                )
        }
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

        var isCreatingNewPark: Bool {
            switch self {
            case .createNew: true
            case .editExisting: false
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
        .loadingOverlay(if: isLoading || isLoadingAddress)
        .background(Color.swBackground)
        .onDisappear {
            saveParkTask?.cancel()
            geocodingTask?.cancel()
        }
        .task {
            if mode.isCreatingNewPark {
                await performGeocodingForNewPark()
            }
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
                    let newPark = try await SWClient(with: defaults)
                        .savePark(id: mode.parkId, form: parkForm)
                    if newPark.id != 0 {
                        dismiss()
                        refreshClbk()
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
        guard case let .createNew(model) = mode else { return }

        isLoadingAddress = true
        geocodingTask = Task {
            do {
                let geocodingService = GeocodingService(coordinate: model.coordinate)
                let result = try await geocodingService.makeAddressAndCityId()

                await MainActor.run {
                    parkForm.address = result.address
                    parkForm.cityId = result.cityId
                    isLoadingAddress = false
                }
            } catch {
                await MainActor.run {
                    isLoadingAddress = false
                    // В случае ошибки пользователь может ввести адрес вручную
                    print("Ошибка геокодирования: \(error)")
                }
            }
        }

        await geocodingTask?.value
    }
}

#if DEBUG
#Preview {
    ParkFormScreen(.editExisting(.preview), refreshClbk: {})
        .environmentObject(DefaultsService())
}
#endif
