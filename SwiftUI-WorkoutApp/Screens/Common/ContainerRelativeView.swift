import SwiftUI

/// Для iOS 17+ располагает вьюху внутри `ZStack` с нужным выравниванием относительно контейнера
struct ContainerRelativeView<Content: View>: View {
    let content: Content
    let axes: Axis.Set
    let alignment: Alignment

    init(
        @ViewBuilder content: () -> Content,
        _ axes: Axis.Set = [.vertical],
        alignment: Alignment = .center
    ) {
        self.content = content()
        self.axes = axes
        self.alignment = alignment
    }

    var body: some View {
        if #available(iOS 17.0, *) {
            ZStack {
                Spacer().containerRelativeFrame(axes, alignment: alignment)
                content
            }
        } else {
            content
        }
    }
}

#if DEBUG
#Preview {
    ScrollView {
        ContainerRelativeView {
            VStack {
                ForEach(0 ..< 3, id: \.self) {
                    Text("element #\($0)")
                }
            }
        }
    }
}
#endif
