import Foundation
@testable import SWUtils
import Testing

struct SWUtilsTests {
    // MARK: - withoutHtml

    @Test
    func withoutHtmlBasicTags() {
        let htmlString = "<p>Строка с тегами html.</p>"
        let cleanString = htmlString.withoutHtml()
        #expect(cleanString == "Строка с тегами html.")
    }

    @Test
    func withoutHtmlCompactMode() {
        let htmlString = "<p>Параграф 1</p><p>Параграф 2</p>"
        let cleanString = htmlString.withoutHtml(compact: true)
        #expect(cleanString == "Параграф 1 Параграф 2")
    }

    @Test
    func withoutHtmlFullMode() {
        let htmlString = "<p>Параграф 1</p><p>Параграф 2</p>"
        let cleanString = htmlString.withoutHtml(compact: false)
        #expect(cleanString == "Параграф 1\n\nПараграф 2")
    }

    @Test
    func withoutHtmlBrTag() {
        let htmlString = "Строка 1<br>Строка 2<br/>Строка 3"
        #expect(htmlString.withoutHtml(compact: true) == "Строка 1 Строка 2 Строка 3")
        #expect(htmlString.withoutHtml(compact: false) == "Строка 1\nСтрока 2\nСтрока 3")
    }

    @Test
    func withoutHtmlEntities() {
        let htmlString = "&amp; &lt; &gt; &nbsp; &quot; &#39;"
        let cleanString = htmlString.withoutHtml()
        #expect(cleanString == "& < >   \" '")
    }

    @Test
    func withoutHtmlOrEmpty() {
        let htmlString: String? = "<p>Test</p>"
        let nilString: String? = nil
        #expect(htmlString.withoutHtmlOrEmpty() == "Test")
        #expect(nilString.withoutHtmlOrEmpty() == "")
    }

    @Test
    func withoutHtmlEmptyString() {
        let emptyString = ""
        #expect(emptyString.withoutHtml() == "")
    }

    // MARK: - Other tests

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
