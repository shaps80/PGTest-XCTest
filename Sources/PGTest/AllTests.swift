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
public typealias AllTests<T> = [(String, (T) -> () -> Void)]

public protocol AllTestsProvider {
    static var allTests: AllTests<Self> { get }
}
extension XCTestCase: AllTestsProvider { }

public extension AllTestsProvider {
    static var allTests: AllTests<Self> { [] }
}
