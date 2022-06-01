import SwiftUI
import CoreLocation.CLLocation

/// Экран с формой для создания/изменения площадки
struct SportsGroundFormView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel: SportsGroundFormViewModel
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var isShowingPicker = false
    @FocusState private var isFocused: Bool
    private let refreshClbk: () -> Void
    @State private var saveGroundTask: Task<Void, Never>?

    init(_ mode: Mode, refreshClbk: @escaping () -> Void) {
        switch mode {
        case let .createNew(address, coordinate, cityID):
            _viewModel = StateObject(
                wrappedValue: .init(
                    address.wrappedValue,
                    coordinate.wrappedValue.latitude,
                    coordinate.wrappedValue.longitude,
                    cityID
                )
            )
        case let .editExisting(ground):
            _viewModel = StateObject(wrappedValue: .init(with: ground))
        }
        self.refreshClbk = refreshClbk
    }

    var body: some View {
        ZStack {
            Form {
                addressSection
                typePicker
                sizePicker
                if !viewModel.newImages.isEmpty {
                    pickedImagesList
                }
                pickImagesButton
            }
            .opacity(viewModel.isLoading ? 0.5 : 1)
            .animation(.easeInOut, value: viewModel.isLoading)
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : .zero)
        }
        .disabled(viewModel.isLoading)
        .sheet(isPresented: $isShowingPicker) {
            ImagePicker(
                selectedImages: $viewModel.newImages,
                showPicker: $isShowingPicker
            )
        }
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .alert(alertMessage, isPresented: $showErrorAlert) {
            Button(action: closeAlert) { TextOk() }
        }
        .onChange(of: viewModel.isSuccess, perform: dismiss)
        .onDisappear(perform: cancelTask)
        .toolbar { saveButton }
        .navigationTitle("Площадка")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension SportsGroundFormView {
    enum Mode {
        case createNew(
            address: Binding<String>,
            coordinate: Binding<CLLocationCoordinate2D>,
            cityID: Int
        )
        case editExisting(SportsGround)
    }
}

private extension SportsGroundFormView {
    var addressSection: some View {
        Section("Адрес площадки") {
            TextField("Улица, номер дома или локация", text: $viewModel.groundForm.address)
                .focused($isFocused)
        }
    }

    var typePicker: some View {
        Picker("Тип площадки", selection: $viewModel.groundForm.typeID) {
            ForEach(SportsGroundGrade.allCases.map(\.code), id: \.self) {
                Text(SportsGroundGrade(id: $0).rawValue)
            }
        }
    }

    var sizePicker: some View {
        Section("Размер площадки") {
            Picker("Размер площадки", selection: $viewModel.groundForm.sizeID) {
                ForEach(SportsGroundSize.allCases.map(\.code), id: \.self) {
                    Text(SportsGroundSize(id: $0).rawValue)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    var pickedImagesList: some View {
        Section("Фотографии") {
            PickedImagesList(images: $viewModel.newImages)
        }
    }

    var pickImagesButton: some View {
        AddPhotoButton(
            isAddingPhotos: $isShowingPicker,
            focusClbk: { isFocused = false }
        )
        .disabled(!viewModel.canAddImages)
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        alertMessage = message
    }

    var saveButton: some View {
        Button(action: saveAction) {
            Text("Сохранить")
        }
        .disabled(!viewModel.isFormReady || viewModel.isLoading)
    }

    func saveAction() {
        isFocused = false
        saveGroundTask = Task {
            await viewModel.saveGround(with: defaults)
        }
    }

    func closeAlert() {
        viewModel.clearErrorMessage()
    }

    func dismiss(isSuccess: Bool) {
        dismiss()
        refreshClbk()
        if viewModel.isNewSportsGround {
            defaults.setUserNeedUpdate(true)
        }
    }

    func cancelTask() {
        saveGroundTask?.cancel()
    }
}

struct CreateOrEditGroundView_Previews: PreviewProvider {
    static var previews: some View {
        SportsGroundFormView(.editExisting(.mock), refreshClbk: {})
            .environmentObject(DefaultsService())
    }
}
