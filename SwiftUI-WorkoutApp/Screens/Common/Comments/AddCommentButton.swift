import SwiftUI

@available(*, deprecated, message: "Use SWButtonStyle instead")
struct AddCommentButton: View {
    @Binding var isCreatingComment: Bool

    var body: some View {
        Button {
            isCreatingComment.toggle()
        } label: {
            Label("Добавить комментарий", systemImage: "plus.message.fill")
                .foregroundColor(.blue)
        }
    }
}

#if DEBUG
struct AddCommentButton_Previews: PreviewProvider {
    static var previews: some View {
        AddCommentButton(isCreatingComment: .constant(false))
            .previewLayout(.sizeThatFits)
    }
}
#endif
