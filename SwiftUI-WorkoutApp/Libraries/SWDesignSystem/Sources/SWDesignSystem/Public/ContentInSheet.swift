import SwiftUI

/// Обертка для представления контента в модальном окне с готовым хедером
public struct ContentInSheet<Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    private let title: LocalizedStringKey
    private var spacing: CGFloat?
    private let content: Content

    public init(
        title: LocalizedStringKey,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        VStack(spacing: spacing) {
            headerForSheet
            content
        }
        .background(Color.swBackground)
    }
}

private extension ContentInSheet {
    var headerForSheet: some View {
        Text(title)
            .lineLimit(1)
            .font(.headline)
            .foregroundStyle(Color.swMainText)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 50)
            .overlay(alignment: .trailing) {
                CloseButton(mode: .xmark) {
                    dismiss()
                }
                .padding(.trailing)
            }
            .padding(.top, 26)
            .padding(.bottom, 10)
    }
}

#if DEBUG
#Preview {
    ContentInSheet(title: "Header") {
        Text("Some content")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.yellow)
    }
}
#endif
