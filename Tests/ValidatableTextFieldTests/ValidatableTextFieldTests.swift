import XCTest
@testable import ValidatableTextField

final class ValidatableTextFieldTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(ValidatableTextField().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
