import SwiftUI

public struct TextWithCheckmarkRowView: View {
    private let text: String
    private let isChecked: Bool

    public init(text: String, isChecked: Bool) {
        self.text = text
        self.isChecked = isChecked
    }

    public var body: some View {
        HStack(spacing: 10) {
            Text(.init(text))
                .lineLimit(1)
                .foregroundColor(.swMainText)
                .frame(maxWidth: .infinity, alignment: .leading)
            if isChecked {
                Image(systemName: "checkmark")
                    .foregroundColor(.swAccent)
            }
        }
        .padding(12)
        .contentShape(Rectangle())
        .animation(.default, value: isChecked)
    }
}

#if DEBUG
#Preview {
    TextWithCheckmarkRowView(text: "Checked text", isChecked: true)
        .insideCardBackground(padding: 0)
        .padding()
        .previewLayout(.sizeThatFits)
}
#endif
