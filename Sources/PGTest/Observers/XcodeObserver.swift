import Foundation

public extension XCTestObservation where Self == XcodeObserver {
    static var verbose: XcodeObserver { XcodeObserver() }
}

/// Mirrors the Apple Xcode output exactly.
public class XcodeObserver: XCTestObservation {
    public func testBundleWillStart(_ testBundle: Bundle) {}

    public func testSuiteWillStart(_ testSuite: XCTestSuite) {
        printAndFlush("Test Suite '\(testSuite.name)' started at \(dateFormatter.string(from: testSuite.testRun!.startDate!))")
    }

    public func testCaseWillStart(_ testCase: XCTestCase) {
        printAndFlush("Test Case '\(testCase.name)' started at \(dateFormatter.string(from: testCase.testRun!.startDate!))")
    }

    public func testCase(_ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: Int) {
        let file = filePath ?? "<unknown>"
        printAndFlush("\(file):\(lineNumber): error: \(testCase.name) : \(description)")
    }

    public func testCaseDidFinish(_ testCase: XCTestCase) {
        let testRun = testCase.testRun!

        let verb: String
        if testRun.hasSucceeded {
            if testRun.hasBeenSkipped {
                verb = "skipped"
            } else {
                verb = "passed"
            }
        } else {
            verb = "failed"
        }

        printAndFlush("Test Case '\(testCase.name)' \(verb) (\(formatTimeInterval(testRun.totalDuration)) seconds)")
    }

    public func testSuiteDidFinish(_ testSuite: XCTestSuite) {
        let testRun = testSuite.testRun!
        let verb = testRun.hasSucceeded ? "passed" : "failed"
        printAndFlush("Test Suite '\(testSuite.name)' \(verb) at \(dateFormatter.string(from: testRun.stopDate!))")

        let tests = testRun.executionCount == 1 ? "test" : "tests"
        let skipped = testRun.skipCount > 0 ? "\(testRun.skipCount) test\(testRun.skipCount != 1 ? "s" : "") skipped and " : ""
        let failures = testRun.totalFailureCount == 1 ? "failure" : "failures"

        printAndFlush("""
            \t Executed \(testRun.executionCount) \(tests), \
            with \(skipped)\
            \(testRun.totalFailureCount) \(failures) \
            (\(testRun.unexpectedExceptionCount) unexpected) \
            in \(formatTimeInterval(testRun.testDuration)) (\(formatTimeInterval(testRun.totalDuration))) seconds
            """
        )
    }

    public func testBundleDidFinish(_ testBundle: Bundle) {}

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()

    fileprivate func printAndFlush(_ message: String) {
        print(message)
        #if !os(Android)
        fflush(stdout)
        #endif
    }

    public func formatTimeInterval(_ timeInterval: TimeInterval) -> String {
        return String(round(timeInterval * 1000.0) / 1000.0)
    }
}

extension XcodeObserver: XCTestInternalObservation {
    func testCase(_ testCase: XCTestCase, wasSkippedWithDescription description: String, at sourceLocation: SourceLocation?) {
        let file = sourceLocation?.file ?? "<unknown>"
        let line = sourceLocation?.line ?? 0
        printAndFlush("\(file):\(line): \(testCase.name) : \(description)")
    }

    func testCase(_ testCase: XCTestCase, didMeasurePerformanceResults results: String, file: StaticString, line: Int) {
        printAndFlush("\(file):\(line): Test Case '\(testCase.name)' measured \(results)")
    }
}
