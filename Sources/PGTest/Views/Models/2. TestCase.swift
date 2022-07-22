import SwiftUI

internal struct TestCase: Identifiable, Hashable {
    var id: String
    var name: String
    var isEnabled: Bool = true
}

extension TestCase: Comparable {
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.name < rhs.name
    }
}

internal extension TestCase {
    var code: String {
        "(\"\(name)\", \(name)),"
    }
}
