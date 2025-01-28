import SWAlert
import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient

/// Экран для смены пароля
struct ChangePasswordScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isNetworkConnected) private var isNetworkConnected
    @EnvironmentObject private var defaults: DefaultsService
    @State private var model = PassworModel()
    @State private var isLoading = false
    @State private var isChangeSuccessful = false
    @State private var changePasswordTask: Task<Void, Never>?
    @FocusState private var focus: FocusableField?

    var body: some View {
        VStack(spacing: 22) {
            SectionView(headerWithPadding: "Текущий пароль", mode: .regular) {
                passwordField
            }
            SectionView(headerWithPadding: "Новый пароль", mode: .regular) {
                newPasswordField
            }
            SectionView(headerWithPadding: "Подтверждение пароля", mode: .regular) {
                newRepeatedField
            }
            Spacer()
            changePasswordButton
        }
        .padding()
        .loadingOverlay(if: isLoading)
        .background(Color.swBackground)
        .onChange(of: isChangeSuccessful, perform: performLogout)
        .onDisappear(perform: cancelTask)
        .navigationTitle("Изменить пароль")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension ChangePasswordScreen {
    struct PassworModel {
        struct NewPassword {
            var text = ""
            var isError: Bool { !errorMessage.isEmpty }
            var errorMessage: String {
                text.trueCount < Constants.minPasswordSize
                    && !text.isEmpty
                    ? "Минимум 6 символов"
                    : ""
            }
        }

        struct NewRepeatedPassword {
            var text = ""
            /// Сравнивает с новым паролем и возвращает ошибку, если они не совпадает
            func check(with new: String) -> String {
                guard !text.isEmpty else { return "" }
                return text == new ? "" : "Пароли должны совпадать"
            }
        }

        var current = ""
        var new = NewPassword()
        var newRepeated = NewRepeatedPassword()

        var isReady: Bool {
            [current, new.text].allSatisfy {
                $0.trueCount >= Constants.minPasswordSize
            }
                && new.text == newRepeated.text
        }
    }

    enum FocusableField: Hashable {
        case current, new, newRepeated
    }

    var canChangePassword: Bool {
        model.isReady && isNetworkConnected
    }

    var passwordField: some View {
        SWTextField(
            placeholder: "Введите пароль",
            text: $model.current,
            isSecure: true,
            isFocused: focus == .current
        )
        .focused($focus, equals: .current)
        .onAppear(perform: showKeyboard)
    }

    func showKeyboard() {
        guard focus == nil else { return }
        Task {
            try await Task.sleep(nanoseconds: 500_000_000)
            focus = .current
        }
    }

    var newPasswordField: some View {
        SWTextField(
            placeholder: "Введите новый пароль",
            text: $model.new.text,
            isSecure: true,
            isFocused: focus == .new,
            errorState: model.new.isError
                ? .message(model.new.errorMessage)
                : nil
        )
        .focused($focus, equals: .new)
    }

    var newRepeatedField: some View {
        let errorMessage = model.newRepeated.check(with: model.new.text)
        return SWTextField(
            placeholder: "Новый пароль ещё раз",
            text: $model.newRepeated.text,
            isSecure: true,
            isFocused: focus == .newRepeated,
            errorState: errorMessage.isEmpty ? nil : .message(errorMessage)
        )
        .focused($focus, equals: .newRepeated)
    }

    var changePasswordButton: some View {
        Button("Сохранить изменения", action: changePasswordAction)
            .buttonStyle(SWButtonStyle(mode: .filled, size: .large))
            .disabled(!canChangePassword)
    }

    func changePasswordAction() {
        guard !isLoading else { return }
        focus = nil
        isLoading.toggle()
        changePasswordTask = Task {
            do {
                isChangeSuccessful = try await SWClient(with: defaults)
                    .changePassword(current: model.current, new: model.new.text)
            } catch {
                SWAlert.shared.present(
                    title: "Ошибка".localized,
                    message: ErrorFilter.message(from: error)
                )
            }
            isLoading.toggle()
        }
    }

    func performLogout(needRelogin: Bool) {
        if needRelogin {
            defaults.triggerLogout()
        }
    }

    func cancelTask() {
        changePasswordTask?.cancel()
    }
}

#if DEBUG
#Preview {
    ChangePasswordScreen()
}
#endif
