import SwiftUI

extension EnvironmentValues {
    @Entry var analyticsService = AnalyticsService(providers: [NoopAnalyticsProvider()])
}
