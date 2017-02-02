import XCTest
@testable import KittenORM

class KittenORMTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(KittenORM().text, "Hello, World!")
    }


    static var allTests : [(String, (KittenORMTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
