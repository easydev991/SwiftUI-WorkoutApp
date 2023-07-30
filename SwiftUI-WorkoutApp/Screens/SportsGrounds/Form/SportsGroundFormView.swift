import CoreLocation.CLLocation
import DesignSystem
import ImagePicker
import NetworkStatus
import SwiftUI
import SWModels

/// Экран с формой для создания/изменения площадки
struct SportsGroundFormView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var network: NetworkStatus
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel: SportsGroundFormViewModel
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var showImagePicker = false
    @State private var saveGroundTask: Task<Void, Never>?
    @FocusState private var isFocused: Bool
    private let refreshClbk: () -> Void

    init(_ mode: Mode, refreshClbk: @escaping () -> Void) {
        switch mode {
        case let .createNew(address, coordinate, cityID):
            _viewModel = StateObject(
                wrappedValue: .init(
                    address,
                    coordinate.latitude,
                    coordinate.longitude,
                    cityID
                )
            )
        case let .editExisting(ground):
            _viewModel = StateObject(wrappedValue: .init(with: ground))
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
        .loadingOverlay(if: viewModel.isLoading)
        .background(Color.swBackground)
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .alert(alertMessage, isPresented: $showErrorAlert) {
            Button("Ok", action: closeAlert)
        }
        .onChange(of: viewModel.isSuccess, perform: dismiss)
        .onDisappear(perform: cancelTask)
        .navigationTitle("Площадка")
        .navigationBarTitleDisplayMode(.inline)
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
    }
}

private extension SportsGroundFormView {
    var addressSection: some View {
        SectionView(header: "Адрес", mode: .regular) {
            SWTextField(
                placeholder: "Адрес площадки",
                text: $viewModel.groundForm.address,
                isFocused: isFocused
            )
            .focused($isFocused)
        }
        .padding(.top, 22)
    }

    var typePicker: some View {
        Menu {
            Picker("", selection: $viewModel.groundForm.typeID) {
                ForEach(SportsGroundGrade.allCases.map(\.code), id: \.self) {
                    Text(SportsGroundGrade(id: $0).rawValue)
                }
            }
        } label: {
            ListRowView(
                leadingContent: .text("Тип площадки"),
                trailingContent: .text(viewModel.groundForm.gradeString)
            )
        }
    }

    var sizePicker: some View {
        Menu {
            Picker("", selection: $viewModel.groundForm.sizeID) {
                ForEach(SportsGroundSize.allCases.map(\.code), id: \.self) {
                    Text(SportsGroundSize(id: $0).rawValue)
                }
            }
        } label: {
            ListRowView(
                leadingContent: .text("Размер площадки"),
                trailingContent: .text(viewModel.groundForm.sizeString)
            )
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

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        alertMessage = message
    }

    var saveButton: some View {
        Button("Сохранить") {
            isFocused = false
            saveGroundTask = Task {
                await viewModel.saveGround(with: defaults)
            }
        }
        .buttonStyle(SWButtonStyle(mode: .filled, size: .large))
        .disabled(
            !viewModel.isFormReady
                || viewModel.isLoading
                || !network.isConnected
        )
    }

    func closeAlert() {
        viewModel.clearErrorMessage()
    }

    func dismiss(isSuccess: Bool) {
        if isSuccess {
            dismiss()
            refreshClbk()
            if viewModel.isNewSportsGround {
                defaults.setUserNeedUpdate(true)
            }
        }
    }

    func cancelTask() {
        saveGroundTask?.cancel()
    }
}

#if DEBUG
struct CreateOrEditGroundView_Previews: PreviewProvider {
    static var previews: some View {
        SportsGroundFormView(.editExisting(.preview), refreshClbk: {})
            .environmentObject(NetworkStatus())
            .environmentObject(DefaultsService())
    }
}
#endif
