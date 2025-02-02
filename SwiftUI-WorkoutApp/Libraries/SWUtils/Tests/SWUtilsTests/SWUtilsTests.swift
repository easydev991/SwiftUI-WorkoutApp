import Foundation
@testable import SWUtils
import Testing

struct SWUtilsTests {
    @Test
    func stringWithoutHTML() {
        let htmlString = "<p>Строка с тегами html.<p>"
        let cleanString = htmlString.withoutHTML
        #expect(cleanString == "Строка с тегами html.")
    }

    @Test
    func trueCountIsOne() {
        let testString = " 1"
        #expect(testString.trueCount == 1)
    }

    @Test
    func trueCountIsZero() {
        let testString = " "
        #expect(testString.trueCount == 0)
    }

    @Test
    func withoutSpaces() {
        let stringWithSpaces = "Hello World from workout"
        let cleanString = stringWithSpaces.withoutSpaces
        #expect(cleanString == "HelloWorldfromworkout")
    }

    @Test
    func capitalizingFirstLetter() {
        let string = "test string"
        let newString = string.capitalizingFirstLetter
        #expect(newString == "Test string")
    }

    @Test
    func queryAllowedURL() {
        let urlString: String? = "https://workout.su/uploads/userfiles/св3.jpg"
        let resultURL = urlString.queryAllowedURL
        #expect(resultURL == URL(string: "https://workout.su/uploads/userfiles/%D1%81%D0%B23.jpg"))
    }
}
