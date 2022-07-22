import SwiftUI

internal struct TestSuite: Identifiable, Hashable {
    var id: String { name }
    var name: String
    var keyedTestCases: [TestCase.ID: TestCase] = [:]
    var testCases: [TestCase] = []
    var isEnabled: Bool {
        testCases.contains { $0.isEnabled }
    }
}

extension TestSuite: Comparable {
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.name < rhs.name
    }
}

internal extension TestSuite {
    var code: String {
        var lines = ["extension \(name) {"]
        lines.append("\tstatic var allTests = [")
        testCases.forEach {
            lines.append("\t\t(\"\($0.name)\", \($0.name)),")
        }
        lines.append("\t]")
        lines.append("}")
        return lines.joined(separator: "\n")
    }
}
