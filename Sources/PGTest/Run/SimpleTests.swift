import Foundation

final class SimpleTests: XCTestCase {
    func testSomethingSimple() {
        sleep(1)
        XCTAssertEqual(Locale(identifier: "en_GB"), .current)
    }

    func testSomethingComplex() {
        sleep(1)
        XCTAssert(true)
    }
}
