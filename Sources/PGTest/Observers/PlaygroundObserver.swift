import SwiftUI

internal class PlaygroundObserver: XCTestObservation, ObservableObject {
    @Published private(set) var testRuns: [TestCase.ID: TestRun] = [:]
    @Published private(set) var runtime: TimeInterval = 0
    @Published private(set) var suites: [TestSuite] = []
    @Published private(set) var missing: [TestCase] = []
    @Published private(set) var failureCount: Int = 0
    @Published private(set) var passedCount: Int = 0
    @Published private(set) var state: TestRun.State = .undetermined

    @AppStorage("randomizeExecutionOrder") private var randomizeExecutionOrder: Bool = true

    private var startDate: Date = .now

    var testCount: Int {
        suites
            .flatMap { $0.testCases }
            .count
    }

    var disabledTestCount: Int {
        suites
            .flatMap { $0.testCases }
            .filter { !$0.isEnabled }
            .count
    }

    var code: String {
        var lines = ["import PGTest"]
        lines.append(
            suites
                .map { $0.code }
                .joined(separator: "\n\n")
        )
        return lines.joined(separator: "\n\n")
    }

    var explicitTestCases: [XCTestCase.Type]

    init(@TestCaseBuilder testCases explicitTestCases: () -> [XCTestCase.Type]) {
        self.explicitTestCases = explicitTestCases()

        var explicit: [String: [String]] = [:]
        for testCase in self.explicitTestCases {
            explicit[String(describing: testCase)] = testCase.allTests.map { $0.0 }
        }

        // use obj-c runtime to discover implicitly defined suites, disabling those that are not also explicitly define
        suites = implicitSuites(explicit: explicit).sorted()
        
        do {
            guard let data = UserDefaults.standard.data(forKey: "testRuns") else { return }
            testRuns = try JSONDecoder().decode([TestCase.ID: TestRun].self, from: data)
        } catch {
            testRuns = [:]
        }
        
        #warning("Remove testRuns from cache, where there's no longer a matching testCase found (implicitly)")
    }

    func state(for testCase: TestCase) -> TestRun.State {
        guard testCase.isEnabled else { return .skipped }
        return testRuns.first { $0.key == testCase.id }?.value.state
        ?? .undetermined
    }

    public func run(selectedTests: [String] = []) {
        guard state != .running else { return }
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            let tests = self.explicitTestCases
                .map {
                    PGTest.testCase(
                        self.randomizeExecutionOrder
                        ? $0.allTests.shuffled()
                        : $0.allTests
                    )
                }

            RunTests(
                randomizeExecutionOrder ? tests.shuffled() : tests,
                arguments: selectedTests,
                observers: [self]
            )
        }
    }

    func testBundleWillStart(_ testBundle: Bundle) {
        DispatchQueue.main.async { [unowned self] in
            withAnimation(.reveal) {
                self.testRuns = [:]
                self.startDate = .now
            }

            self.state = .running
            self.runtime = 0
            self.failureCount = 0
            self.passedCount = 0
        }
    }

    func testSuiteWillStart(_ testSuite: XCTestSuite) {
        DispatchQueue.main.async { [unowned self] in
            withAnimation(.reveal) {
                testSuite.tests
                    .forEach {
                        self.testRuns[$0.name] = .init(
                            id: $0.name,
                            state: .running
                        )
                    }
            }
        }
    }

    func testCase(_ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: Int) {
        DispatchQueue.main.async { [unowned self] in
            withAnimation(.reveal) {
                self.testRuns[testCase.name]?.state = .failed(.init(errorDescription: description))
            }
            self.failureCount += 1
        }
    }

    func testCaseDidFinish(_ testCase: XCTestCase) {
        DispatchQueue.main.async { [unowned self] in
            let testRun = testCase.testRun!
            guard testRun.hasSucceeded else { return }
            withAnimation(.reveal) {
                self.testRuns[testCase.name]?.state = .passed
            }
            self.passedCount += 1
        }
    }

    func testBundleDidFinish(_ testBundle: Bundle) {
        DispatchQueue.main.async { [unowned self] in
            withAnimation(.reveal) {
                self.runtime = Date.now.timeIntervalSince(self.startDate)

                func complete() {
                    if self.failureCount > 0 {
                        self.state = .failed(.init())
                    } else if self.runtime == 0 {
                        self.state = .undetermined
                    } else {
                        self.state = .passed
                    }
                }

                if self.runtime < 0.4 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        complete()
                    }
                } else {
                    complete()
                }
            }
        }
        
        do {
            let data = try JSONEncoder().encode(testRuns)
            UserDefaults.standard.set(data, forKey: "testRuns")
        } catch {
            print("Failed to cache testRuns")
        }
    }

    func formatTimeInterval(_ timeInterval: TimeInterval) -> String {
        return String(round(timeInterval * 1000.0) / 1000.0)
    }
}

private extension PlaygroundObserver {
    var testCases: [XCTestCase.Type] {
        let expectedClassCount = objc_getClassList(nil, 0)
        let allClasses = UnsafeMutablePointer<AnyClass?>.allocate(capacity: Int(expectedClassCount))

        let autoreleasingAllClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(allClasses)
        let actualClassCount: Int32 = objc_getClassList(autoreleasingAllClasses, expectedClassCount)

        var providers: [XCTestCase.Type] = []

        for i in 0 ..< actualClassCount {
            if let classType: AnyClass = allClasses[Int(i)],
               class_getSuperclass(classType) == XCTestCase.self,
               let provider = classType as? XCTestCase.Type {
                providers.append(provider)
            }
        }

        allClasses.deallocate()
        return providers
    }

    func implicitSuites(explicit: [String: [String]]) -> [TestSuite] {
        testCases.map { testCase in
            var suite = TestSuite(
                name: String(describing: testCase)
            )

            let className = String(describing: testCase)
            var methodCount: UInt32 = 0

            if let methodList = class_copyMethodList(testCase, &methodCount) {
                for i in 0..<Int(methodCount) {
                    let selector = method_getName(methodList[i])

                    if selector.description.hasPrefix("test") {
                        let name = String("\(selector)")
                        let id = "\(className).\(name)"
                        let isEnabled = explicit[String(describing: testCase)]?.contains(name) == true

                        let test = TestCase(
                            id: id,
                            name: name,
                            isEnabled: isEnabled
                        )

                        suite.append(test)
                    }
                }
            }

            return suite
        }
    }
}
