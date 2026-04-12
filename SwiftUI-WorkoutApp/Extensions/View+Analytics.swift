import SwiftUI

private struct ScreenAnalyticsModifier: ViewModifier {
    @Environment(\.analyticsService) private var analytics
    let screen: AnalyticsEvent.AppScreen
    let source: AnalyticsEvent.AppScreen?

    func body(content: Content) -> some View {
        content.onAppear {
            analytics.log(.screenView(screen: screen, source: source))
        }
    }
}

extension View {
    func trackScreen(_ screen: AnalyticsEvent.AppScreen, source: AnalyticsEvent.AppScreen? = nil) -> some View {
        modifier(ScreenAnalyticsModifier(screen: screen, source: source))
    }
}
