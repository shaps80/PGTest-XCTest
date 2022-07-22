import SwiftUI

public class PlaygroundObserver: XCTestObservation, ObservableObject {
    @Published private(set) var testRuns: [TestCase.ID: TestRun] = [:]
    @Published private(set) var isRunning: Bool = false
    @Published private(set) var runtime: TimeInterval = 0
    
    private var startDate: Date = .now
    
    @Published private(set) var suites: [TestSuite] = []
    @Published private(set) var missing: [TestCase] = []

    var code: String {
        var lines = ["import PGTest"]
        lines.append(
            suites
                .map { $0.code }
                .joined(separator: "\n\n")
        )
        return lines.joined(separator: "\n\n")
    }

    public init() {
        #warning("Ideally this could be done automatically here")

        var explicit: [String: [String]] = [:]
        for testCase in testCases {
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
        
        #warning("Remove testRuns where there's no longer a testCase")
    }
    
    func state(for testCase: TestCase) -> TestRun.State {
        guard testCase.isEnabled else { return .skipped }
        return testRuns.first { $0.key == testCase.id }?.value.state
        ?? .undetermined
    }
    
    public func run(selectedTests: [String] = []) {
        RunTests(
            testCases.map { PGTest.testCase($0.allTests) },
            arguments: selectedTests,
            observers: [self]
        )
    }
    
    public func testBundleWillStart(_ testBundle: Bundle) {
        withAnimation(.reveal) {
            testRuns = [:]
            startDate = .now
            isRunning = true
            runtime = 0
        }
    }
    
    public func testCaseWillStart(_ testCase: XCTestCase) { }
    
    public func testCase(_ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: Int) {
        withAnimation(.reveal) { 
            testRuns[testCase.name] = .init(id: testCase.name, state: .failed(.init(errorDescription: description)))
        }
    }
    
    public func testCaseDidFinish(_ testCase: XCTestCase) {
        let testRun = testCase.testRun!
        guard testRun.hasSucceeded else { return }
        withAnimation(.reveal) {
            testRuns[testCase.name] = .init(id: testCase.name, state: .passed)
        }
    }
    
    public func testBundleDidFinish(_ testBundle: Bundle) {
        withAnimation(.reveal) {
            runtime = Date.now.timeIntervalSince(startDate) 
            isRunning = false
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

                        if suite.keyedTestCases[id] == nil {
                            suite.keyedTestCases[id] = test
                            suite.testCases.append(test)
                        }
                    }
                }
            }

            return suite
        }
    }
}
