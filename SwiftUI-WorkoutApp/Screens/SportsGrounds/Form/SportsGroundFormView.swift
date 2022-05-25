import SwiftUI

/// Экран с формой для создания/изменения площадки
struct SportsGroundFormView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel: SportsGroundFormViewModel
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @FocusState private var isFocused: Bool
    @Binding private var needRefreshOnSave: Bool
    @State private var saveGroundTask: Task<Void, Never>?

    init(
        with ground: SportsGround? = nil,
        needRefreshOnSave: Binding<Bool>
    ) {
        _viewModel = StateObject(wrappedValue: .init(with: ground))
        self._needRefreshOnSave = needRefreshOnSave
    }

    var body: some View {
        ZStack {
            Form {
                addressSection
            }
            .opacity(viewModel.isLoading ? 0.5 : 1)
            .animation(.easeInOut, value: viewModel.isLoading)
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : .zero)
        }
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

private extension SportsGroundFormView {
    var addressSection: some View {
        Section {
            TextField("Адрес", text: $viewModel.groundForm.address)
                .focused($isFocused)
        }
    }
    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        alertMessage = message
    }

    var saveButton: some View {
        Button(action: saveAction) {
            Text("Сохранить")
        }
        .disabled(!viewModel.groundForm.isReadyToSend || viewModel.isLoading)
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
        needRefreshOnSave.toggle()
    }

    func cancelTask() {
        saveGroundTask?.cancel()
    }
}

struct CreateOrEditGroundView_Previews: PreviewProvider {
    static var previews: some View {
        SportsGroundFormView(with: .mock, needRefreshOnSave: .constant(false))
            .environmentObject(DefaultsService())
    }
}
