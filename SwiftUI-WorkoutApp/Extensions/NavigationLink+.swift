import SwiftUI

extension NavigationLink where Label == EmptyView {
    /// Инициализатор для `NavigationLink` без лейбла
    init(destination: Destination, isActive: Binding<Bool>) {
        self.init(
            destination: destination,
            isActive: isActive,
            label: EmptyView.init
        )
    }
}
