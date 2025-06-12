@testable import CachedAsyncImage
import Testing
import UIKit

struct CurrentViewStateTests {
    @Test
    func hasUIImage() {
        let testImage = UIImage()
        let readyState = CurrentViewState.ready(testImage)
        #expect(readyState.uiImage === testImage)
    }

    @Test(arguments: [CurrentViewState.initial, .loading, .error])
    func noImage(state: CurrentViewState) {
        #expect(state.uiImage == nil)
    }

    @Test
    func shouldLoadProperty() {
        #expect(!CurrentViewState.loading.shouldLoad)
        #expect(!CurrentViewState.ready(UIImage()).shouldLoad)
        #expect(CurrentViewState.initial.shouldLoad)
        #expect(CurrentViewState.error.shouldLoad)
    }
}
