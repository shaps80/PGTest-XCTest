@_exported import Foundation

public func RunTests(_ testCases: [XCTestCaseEntry]) {
    RunTests(testCases, arguments: CommandLine.arguments)
}

public func RunTests(_ testCases: [XCTestCaseEntry], arguments: [String]) {
    RunTests(testCases, arguments: arguments, observers: [PrintObserver()])
}

public func RunTests(
    _ testCases: [XCTestCaseEntry],
    arguments: [String],
    observers: [XCTestObservation]
) {
    let testBundle = Bundle.main

    let executionMode = ArgumentParser(arguments: arguments).executionMode

    // Apple XCTest behaves differently if tests have been filtered:
    // - The root `XCTestSuite` is named "Selected tests" instead of
    //   "All tests".
    // - An `XCTestSuite` representing the .xctest test bundle is not included.
    let rootTestSuite: XCTestSuite
    let currentTestSuite: XCTestSuite
    if executionMode.selectedTestNames == nil {
        rootTestSuite = XCTestSuite(name: "All tests")
        currentTestSuite = XCTestSuite(name: "\(testBundle.bundleURL.lastPathComponent).xctest")
        rootTestSuite.addTest(currentTestSuite)
    } else {
        rootTestSuite = XCTestSuite(name: "Selected tests")
        currentTestSuite = rootTestSuite
    }

    let filter = TestFiltering(selectedTestNames: executionMode.selectedTestNames)
    TestFiltering.filterTests(testCases, filter: filter.selectedTestFilter)
        .map(XCTestCaseSuite.init)
        .forEach(currentTestSuite.addTest)

    // Add a test observer that prints test progress to stdout.
    let observationCenter = XCTestObservationCenter.shared
    for observer in observers {
        observationCenter.addTestObserver(observer)
    }

    observationCenter.testBundleWillStart(testBundle)
    rootTestSuite.run()
    observationCenter.testBundleDidFinish(testBundle)
}
