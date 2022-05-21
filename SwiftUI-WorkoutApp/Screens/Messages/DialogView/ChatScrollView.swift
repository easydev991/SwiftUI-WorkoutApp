//
//  ChatScrollView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 21.05.2022.
//


import SwiftUI

struct CustomScrollView<Content: View>: View {
    var scrollToEnd = false
    var content: () -> Content

    @State private var contentHeight = CGFloat.zero
    @State private var contentOffset = CGFloat.zero
    @State private var scrollOffset = CGFloat.zero

    var body: some View {
        GeometryReader { geometry in
            content()
                .modifier(ViewHeightKey())
                .onPreferenceChange(ViewHeightKey.self) { height in
                    DispatchQueue.main.async {
                        updateHeight(with: height, outerHeight: geometry.size.height)
                    }
                }
                .frame(height: geometry.size.height, alignment: .top)
                .offset(y: contentOffset + scrollOffset)
                .animation(.default, value: scrollOffset)
                .gesture(DragGesture()
                    .onChanged { onDragChanged($0) }
                    .onEnded { onDragEnded($0, outerHeight: geometry.size.height) }
                )
        }
        .clipped()
    }

    private func onDragChanged(_ value: DragGesture.Value) {
        scrollOffset = value.location.y - value.startLocation.y
    }

    private func onDragEnded(_ value: DragGesture.Value, outerHeight: CGFloat) {
        let scrollOffset = value.predictedEndLocation.y - value.startLocation.y
        updateOffset(with: scrollOffset, outerHeight: outerHeight)
        self.scrollOffset = .zero
    }

    private func updateHeight(with height: CGFloat, outerHeight: CGFloat) {
        let delta = contentHeight - height
        contentHeight = height
        if scrollToEnd {
            contentOffset = outerHeight - height
        }
        if abs(contentOffset) > .zero {
            updateOffset(with: delta, outerHeight: outerHeight)
        }
    }

    private func updateOffset(with delta: CGFloat, outerHeight: CGFloat) {
        let topLimit = contentHeight - outerHeight

        if topLimit < .zero {
             contentOffset = .zero
        } else {
            var proposedOffset = contentOffset + delta
            if -proposedOffset < .zero {
                proposedOffset = .zero
            } else if -proposedOffset > topLimit {
                proposedOffset = -topLimit
            }
            contentOffset = proposedOffset
        }
    }
}

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { .zero }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}

extension ViewHeightKey: ViewModifier {
    func body(content: Content) -> some View {
        content.background(
            GeometryReader { proxy in
                Color.clear.preference(key: Self.self, value: proxy.size.height)
            }
        )
    }
}
