import DesignSystem
import NetworkStatus
import SwiftUI
import SWModels

struct PhotoDetailScreen: View {
    @EnvironmentObject private var network: NetworkStatus
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteDialog = false
    @State private var showReportDialog = false
    let model: Model
    let canDelete: Bool
    let reportPhotoClbk: () -> Void
    let deletePhotoClbk: (Int) -> Void

    var body: some View {
        VStack {
            headerView
            ImageDetailView(image: model.uiImage)
        }
        .background(Color.swBackground)
    }
}

extension PhotoDetailScreen {
    struct Model: Identifiable {
        let uiImage: UIImage
        let id: Int
    }

    enum DialogOption {
        case report, delete

        var title: String {
            switch self {
            case .report: "Пожаловаться на фото"
            case .delete: "Удалить фото"
            }
        }
    }
}

private extension PhotoDetailScreen {
    var headerView: some View {
        ZStack {
            HStack {
                Button("Закрыть") { dismiss() }
                Spacer()
                trailingButton
                    .disabled(!network.isConnected)
            }
            .tint(.swAccent)
            .padding(.horizontal)
            Text("Фото")
                .font(.headline)
                .foregroundColor(.swMainText)
        }
        .padding(.vertical)
    }

    @ViewBuilder
    var trailingButton: some View {
        if canDelete {
            deleteButton
        } else {
            reportButton
        }
    }

    var deleteButton: some View {
        Button {
            showDeleteDialog = true
        } label: {
            Image(systemName: Icons.Regular.trash.rawValue)
        }
        .confirmationDialog(
            DialogOption.delete.title,
            isPresented: $showDeleteDialog,
            titleVisibility: .hidden
        ) {
            Button(
                DialogOption.delete.title,
                role: .destructive
            ) {
                deletePhotoClbk(model.id)
            }
        }
    }

    var reportButton: some View {
        Button {
            showReportDialog = true
        } label: {
            Image(systemName: Icons.Regular.exclamation.rawValue)
        }
        .confirmationDialog(
            DialogOption.report.title,
            isPresented: $showReportDialog,
            titleVisibility: .hidden
        ) {
            Button(
                DialogOption.report.title,
                role: .destructive,
                action: reportPhotoClbk
            )
        }
    }
}

#if DEBUG
#Preview {
    PhotoDetailScreen(
        model: .init(uiImage: .init(), id: 1),
        canDelete: false,
        reportPhotoClbk: {},
        deletePhotoClbk: { _ in }
    )
    .environmentObject(NetworkStatus())
}
#endif
