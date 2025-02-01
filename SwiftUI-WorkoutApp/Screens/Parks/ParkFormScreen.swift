import CoreLocation.CLLocation
import ImagePicker
import SWAlert
import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient

/// Экран с формой для создания/изменения площадки
struct ParkFormScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isNetworkConnected) private var isNetworkConnected
    @EnvironmentObject private var defaults: DefaultsService
    @State private var isLoading = false
    @State private var parkForm: ParkForm
    @State private var newImages = [UIImage]()
    @State private var showImagePicker = false
    @State private var saveParkTask: Task<Void, Never>?
    @FocusState private var isFocused: Bool
    private let oldParkForm: ParkForm
    private let mode: Mode
    private let refreshClbk: () -> Void

    init(_ mode: Mode, refreshClbk: @escaping () -> Void) {
        self.mode = mode
        switch mode {
        case let .createNew(address, coordinate, cityID):
            self.oldParkForm = .init(
                address: address,
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                cityID: cityID
            )
            _parkForm = .init(initialValue: oldParkForm)
        case let .editExisting(park):
            self.oldParkForm = .init(park)
            _parkForm = .init(initialValue: oldParkForm)
        }
        self.refreshClbk = refreshClbk
    }

    var body: some View {
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
        .navigationTitle("Площадка")
        .navigationBarTitleDisplayMode(.inline)
        .interactiveDismissDisabled(isLoading)
    }
}

extension ParkFormScreen {
    enum Mode {
        case createNew(
            address: String,
            coordinate: CLLocationCoordinate2D,
            cityID: Int
        )
        case editExisting(Park)

        var parkID: Int? {
            switch self {
            case .createNew: nil
            case let .editExisting(park): park.id
            }
        }
    }
}

private extension ParkFormScreen {
    var addressSection: some View {
        SectionView(header: "Адрес", mode: .regular) {
            SWTextField(
                placeholder: "Адрес площадки",
                text: $parkForm.address,
                isFocused: isFocused
            )
            .focused($isFocused)
        }
        .padding(.top, 22)
    }

    var typePicker: some View {
        Menu {
            Picker("", selection: $parkForm.typeID) {
                ForEach(ParkGrade.allCases.map(\.code), id: \.self) {
                    Text(.init(ParkGrade(id: $0).rawValue))
                }
            }
        } label: {
            ListRowView(
                leadingContent: .text("Тип площадки"),
                trailingContent: .textWithChevron(.init(parkForm.gradeString))
            )
        }
    }

    var sizePicker: some View {
        Menu {
            Picker("", selection: $parkForm.sizeID) {
                ForEach(ParkSize.allCases.map(\.code), id: \.self) {
                    Text(.init(ParkSize(id: $0).rawValue))
                }
            }
        } label: {
            ListRowView(
                leadingContent: .text("Размер площадки"),
                trailingContent: .textWithChevron(.init(parkForm.sizeString))
            )
        }
    }

    var pickedImagesGrid: some View {
        PickedImagesGrid(
            images: $newImages,
            showImagePicker: $showImagePicker,
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
            isFocused = false
            isLoading = true
            saveParkTask = Task {
                do {
                    let newPark = try await SWClient(with: defaults)
                        .savePark(id: mode.parkID, form: parkForm)
                    if newPark.id != 0 {
                        dismiss()
                        refreshClbk()
                    }
                } catch {
                    SWAlert.shared.presentDefaultUIKit(message: error.localizedDescription)
                }
                isLoading = false
            }
        }
        .buttonStyle(SWButtonStyle(mode: .filled, size: .large))
        .disabled(!isFormReady || !isNetworkConnected)
    }

    var isFormReady: Bool {
        mode.parkID == nil
            ? parkForm.isReadyToCreate
            : parkForm.isReadyToUpdate(old: oldParkForm)
    }
}

#if DEBUG
#Preview {
    ParkFormScreen(.editExisting(.preview), refreshClbk: {})
        .environmentObject(DefaultsService())
}
#endif
