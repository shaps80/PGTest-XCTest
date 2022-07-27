import SwiftUI

public extension XCTestObservation where Self == PlaygroundConsoleObserver {
    static var compact: PlaygroundConsoleObserver { PlaygroundConsoleObserver() }
}

extension XCTestCase {
    var methodName: String {
        name
            .components(separatedBy: ".")
            .dropFirst()
            .joined(separator: ".")
    }
}

public class PlaygroundConsoleObserver: XCTestObservation {
    private var startDate: Date = .now
    private var finishedCount: Int = 0
    private var failureCount: Int = 0
    
    public func testBundleWillStart(_ testBundle: Bundle) {
        startDate = .now
        failureCount = 0
        finishedCount = 0
        printAndFlush("")
    }

    public func testSuiteWillStart(_ testSuite: XCTestSuite) {
        if testSuite.tests.contains(where: { $0 is XCTestCase }) {
            print("- \(testSuite.name) began")
        }
    }
    
    public func testCase(_ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: Int) {
        failureCount += 1
        let message = description.trimmingCharacters(in: .init(arrayLiteral: "-", " "))
        printAndFlush("✗ \(testCase.methodName) (line: \(lineNumber)) – \(message)")
    }
    
    public func testCaseDidFinish(_ testCase: XCTestCase) {
        let testRun = testCase.testRun!
        
        if testRun.hasSucceeded {
            if testRun.hasBeenSkipped {
                printAndFlush("↪ \(testCase.methodName) (skipped)")
            } else {
                printAndFlush("✓ \(testCase.methodName) (\(formatTimeInterval(testRun.totalDuration))s)")
            }
        }

        finishedCount += 1
    }
    
    public func testSuiteDidFinish(_ testSuite: XCTestSuite) {
        if testSuite.tests.contains(where: { $0 is XCTestCase }) {
            let count = testSuite.testRun!.failureCount
            var message = "- \(testSuite.name) ended"
            if count > 0 { message.append(" (\(count) failed)") }
            printAndFlush("\(message)\n")
        }
    }
    
    public func testBundleDidFinish(_ testBundle: Bundle) {
        if finishedCount > 0 {
            var message = "- Tests ended (\(formatTimeInterval(Date.now.timeIntervalSince(startDate)))s"
            if failureCount > 0 { message.append(", \(failureCount) failed")}
            printAndFlush("\(message))")
        } else {
            printAndFlush("No tests to run.")
        }
    }

    fileprivate func printAndFlush(_ message: String) {
        print(message)
        fflush(stdout)
    }
    
    private func formatTimeInterval(_ timeInterval: TimeInterval) -> String {
        return String(round(timeInterval * 1000.0) / 1000.0)
    }
}
