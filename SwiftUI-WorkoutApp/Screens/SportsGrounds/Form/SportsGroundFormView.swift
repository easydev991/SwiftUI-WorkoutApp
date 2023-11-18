import CoreLocation.CLLocation
import ImagePicker
import NetworkStatus
import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient

/// Экран с формой для создания/изменения площадки
struct SportsGroundFormView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var network: NetworkStatus
    @EnvironmentObject private var defaults: DefaultsService
    @State private var isLoading = false
    @State private var groundForm: SportsGroundForm
    @State private var newImages = [UIImage]()
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var showImagePicker = false
    @State private var saveGroundTask: Task<Void, Never>?
    @FocusState private var isFocused: Bool
    private let oldGroundForm: SportsGroundForm
    private let mode: Mode
    private let refreshClbk: () -> Void

    init(_ mode: Mode, refreshClbk: @escaping () -> Void) {
        self.mode = mode
        switch mode {
        case let .createNew(address, coordinate, cityID):
            self.oldGroundForm = .init(
                address: address,
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                cityID: cityID
            )
            _groundForm = .init(initialValue: oldGroundForm)
        case let .editExisting(ground):
            self.oldGroundForm = .init(ground)
            _groundForm = .init(initialValue: oldGroundForm)
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
        .alert(alertMessage, isPresented: $showErrorAlert) {
            Button("Ok") { alertMessage = "" }
        }
        .onDisappear { saveGroundTask?.cancel() }
        .navigationTitle("Площадка")
        .navigationBarTitleDisplayMode(.inline)
        .interactiveDismissDisabled(isLoading)
    }
}

extension SportsGroundFormView {
    enum Mode {
        case createNew(
            address: String,
            coordinate: CLLocationCoordinate2D,
            cityID: Int
        )
        case editExisting(SportsGround)

        var groundID: Int? {
            switch self {
            case .createNew: nil
            case let .editExisting(ground): ground.id
            }
        }
    }
}

private extension SportsGroundFormView {
    var addressSection: some View {
        SectionView(header: "Адрес", mode: .regular) {
            SWTextField(
                placeholder: "Адрес площадки",
                text: $groundForm.address,
                isFocused: isFocused
            )
            .focused($isFocused)
        }
        .padding(.top, 22)
    }

    var typePicker: some View {
        Menu {
            Picker("", selection: $groundForm.typeID) {
                ForEach(SportsGroundGrade.allCases.map(\.code), id: \.self) {
                    Text(.init(SportsGroundGrade(id: $0).rawValue))
                }
            }
        } label: {
            ListRowView(
                leadingContent: .text("Тип площадки"),
                trailingContent: .textWithChevron(.init(groundForm.gradeString))
            )
        }
    }

    var sizePicker: some View {
        Menu {
            Picker("", selection: $groundForm.sizeID) {
                ForEach(SportsGroundSize.allCases.map(\.code), id: \.self) {
                    Text(.init(SportsGroundSize(id: $0).rawValue))
                }
            }
        } label: {
            ListRowView(
                leadingContent: .text("Размер площадки"),
                trailingContent: .textWithChevron(.init(groundForm.sizeString))
            )
        }
    }

    var pickedImagesGrid: some View {
        PickedImagesGrid(
            images: $newImages,
            showImagePicker: $showImagePicker,
            selectionLimit: groundForm.imagesLimit,
            processExtraImages: {
                while groundForm.imagesLimit < 0 {
                    newImages.removeLast()
                }
            }
        )
        .padding(.top, 22)
        .padding(.bottom, 42)
        .onChange(of: newImages) { images in
            groundForm.newMediaFiles = images.toMediaFiles
        }
    }

    func setupErrorAlert(_ message: String) {
        showErrorAlert = !message.isEmpty
        alertMessage = message
    }

    var saveButton: some View {
        Button("Сохранить") {
            isFocused = false
            isLoading = true
            saveGroundTask = Task {
                do {
                    let newGround = try await SWClient(with: defaults)
                        .saveSportsGround(id: mode.groundID, form: groundForm)
                    if newGround.id != 0 {
                        dismiss()
                        refreshClbk()
                    }
                } catch {
                    setupErrorAlert(ErrorFilter.message(from: error))
                }
                isLoading = false
            }
        }
        .buttonStyle(SWButtonStyle(mode: .filled, size: .large))
        .disabled(!isFormReady || !network.isConnected)
    }

    var isFormReady: Bool {
        mode.groundID == nil
            ? groundForm.isReadyToCreate
            : groundForm.isReadyToUpdate(old: oldGroundForm)
    }
}

#if DEBUG
#Preview {
    SportsGroundFormView(.editExisting(.preview), refreshClbk: {})
        .environmentObject(NetworkStatus())
        .environmentObject(DefaultsService())
}
#endif
