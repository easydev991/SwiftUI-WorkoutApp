import SWDesignSystem
import SwiftUI

/// Экран для просмотра фотографии
///
/// Можно пожаловаться на фото или удалить его (в некоторых сценариях)
struct PhotoDetailScreen: View {
    @Environment(\.isNetworkConnected) private var isNetworkConnected
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
            PDFViewRepresentable(image: model.uiImage)
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
                    .disabled(!isNetworkConnected)
            }
            .tint(.swAccent)
            .padding(.horizontal)
            Text("Фото")
                .font(.headline)
                .foregroundStyle(Color.swMainText)
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
            Icons.Regular.trash.view
        }
        .confirmationDialog(
            .init(DialogOption.delete.title),
            isPresented: $showDeleteDialog,
            titleVisibility: .hidden
        ) {
            Button(
                .init(DialogOption.delete.title),
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
            Icons.Regular.exclamation.view
        }
        .confirmationDialog(
            .init(DialogOption.report.title),
            isPresented: $showReportDialog,
            titleVisibility: .hidden
        ) {
            Button(
                .init(DialogOption.report.title),
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
}
#endif
