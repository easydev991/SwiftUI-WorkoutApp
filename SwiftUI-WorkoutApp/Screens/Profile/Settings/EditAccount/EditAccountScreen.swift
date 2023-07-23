import DesignSystem
import NetworkStatus
import SwiftUI
import SWModels

/// Экран для изменения личных данных пользователя
struct EditAccountScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var network: NetworkStatus
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = EditAccountViewModel()
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var editUserTask: Task<Void, Never>?
    @FocusState private var focus: FocusableField?

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                Group {
                    loginField.padding(.top)
                    emailField
                    nameField
                }
                .padding(.bottom, 12)
                genderPicker
                birthdayPicker
                countryPicker
                cityPicker
            }
            Spacer()
            saveChangesButton
        }
        .padding([.horizontal, .bottom])
        .loadingOverlay(if: viewModel.isLoading)
        .background(Color.swBackground)
        .alert(alertMessage, isPresented: $showErrorAlert) {
            Button("Ok") { viewModel.clearErrorMessage() }
        }
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .onChange(of: viewModel.isProfileSaved, perform: close)
        .onAppear { viewModel.updateForm(with: defaults) }
        .onDisappear(perform: cancelTask)
        .navigationTitle("Изменить профиль")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension EditAccountScreen {
    enum FocusableField: Hashable {
        case login, email, fullName
    }

    var loginField: some View {
        SWTextField(
            placeholder: viewModel.userForm.placeholder(.userName),
            text: $viewModel.userForm.userName,
            isFocused: focus == .login
        )
        .focused($focus, equals: .login)
    }

    var emailField: some View {
        SWTextField(
            placeholder: viewModel.userForm.placeholder(.email),
            text: $viewModel.userForm.email,
            isFocused: focus == .email
        )
        .focused($focus, equals: .email)
    }

    var nameField: some View {
        SWTextField(
            placeholder: viewModel.userForm.placeholder(.fullname),
            text: $viewModel.userForm.fullName,
            isFocused: focus == .fullName
        )
        .focused($focus, equals: .fullName)
    }

    var genderPicker: some View {
        Menu {
            Picker("", selection: $viewModel.userForm.genderCode) {
                ForEach(Gender.possibleGenders, id: \.code) {
                    Text($0.rawValue)
                }
            }
        } label: {
            ListRowView(
                leadingContent: .iconWithText(
                    .personQuestion,
                    viewModel.userForm.placeholder(.gender)
                ),
                trailingContent: .text(viewModel.currentGender.rawValue)
            )
        }
    }

    var birthdayPicker: some View {
        HStack(spacing: 12) {
            ListRowView.LeadingContent.makeIconView(with: Icons.ListRow.calendar)
            DatePicker(
                viewModel.userForm.placeholder(.birthDate),
                selection: $viewModel.userForm.birthDate,
                in: ...Constants.minUserAge,
                displayedComponents: .date
            )
        }
        .padding(.vertical, 16)
    }

    var countryPicker: some View {
        NavigationLink {
            ItemListScreen(
                allItems: viewModel.countries.map(\.name),
                selectedItem: viewModel.userForm.country.name,
                didSelectItem: { viewModel.selectCountry(name: $0) }
            )
        } label: {
            ListRowView(
                leadingContent: .iconWithText(
                    .globe,
                    viewModel.userForm.placeholder(.country)
                ),
                trailingContent: .textWithChevron(viewModel.userForm.country.name)
            )
        }
        .padding(.bottom, 6)
    }

    var cityPicker: some View {
        NavigationLink {
            ItemListScreen(
                allItems: viewModel.cities.map(\.name),
                selectedItem: viewModel.userForm.city.name,
                didSelectItem: { viewModel.selectCity(name: $0) }
            )
        } label: {
            ListRowView(
                leadingContent: .iconWithText(
                    .signPost,
                    viewModel.userForm.placeholder(.city)
                ),
                trailingContent: .textWithChevron(viewModel.userForm.city.name)
            )
        }
    }

    var saveChangesButton: some View {
        Button("Сохранить", action: saveChangesAction)
            .buttonStyle(SWButtonStyle(mode: .filled, size: .large))
            .disabled(
                !viewModel.canSaveChanges
                    || !network.isConnected
            )
    }

    func saveChangesAction() {
        editUserTask = Task { await viewModel.saveChangesAction(with: defaults) }
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        alertMessage = message
    }

    func close(_ shouldClose: Bool) {
        if shouldClose { dismiss() }
    }

    func cancelTask() {
        editUserTask?.cancel()
    }
}

#if DEBUG
struct EditAccountScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditAccountScreen()
                .environmentObject(NetworkStatus())
                .environmentObject(DefaultsService())
        }
    }
}
#endif
