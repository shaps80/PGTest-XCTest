import Foundation

/**
 To simplify test definitions, you can use the following typealias:

     final class MyTestCase: XCTestCase {
         static var allTests: AllTests<MyTestCase> = [
             ("testFoo", testFoo),
             ("testBar", testBar),
         ]

         func testFoo() { }
         func testBar() { }
     }

 - Note: You can also generate this code automatically in the
         Test Results screen.

 */
public typealias AllTests<T: XCTestCase> = [(String, (T) -> () -> Void)]

public protocol AllTestsProvider: XCTestCase {
    static var allTests: AllTests<Self> { get }
}

public extension AllTestsProvider {
    static var allTests: AllTests<Self> { [] }
}

extension XCTestCase: AllTestsProvider { }
