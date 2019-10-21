import XCTest
@testable import WindySwift

final class WindySwiftTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(WindySwift().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
