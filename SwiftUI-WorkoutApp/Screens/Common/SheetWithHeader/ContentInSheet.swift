import SwiftUI

/// Обертка для представления контента в модальном окне с готовым хедером
struct ContentInSheet<Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    var spacing: CGFloat? = nil
    let content: () -> Content

    var body: some View {
        VStack(spacing: spacing) {
            headerForSheet
            content()
        }
    }
}

private extension ContentInSheet {
    var headerForSheet: some View {
        HStack {
            Text(title)
                .font(.title3)
                .fontWeight(.medium)
            Spacer()
            Button {
                dismiss()
            } label: {
                Circle()
                    .frame(width: 30, height: 30)
                    .adaptiveColor(radius: 0, .foreground(inverse: false))
                    .opacity(0.6)
                    .overlay {
                        Image(systemName: "xmark")
                            .imageScale(.medium)
                            .adaptiveColor(radius: 0, .foreground())
                    }
            }
        }
        .padding()
    }
}

#if DEBUG
struct ContentInSheet_Previews: PreviewProvider {
    static var previews: some View {
        ContentInSheet(title: "Header") {
            Text("Some content")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.yellow)
        }
    }
}
#endif
