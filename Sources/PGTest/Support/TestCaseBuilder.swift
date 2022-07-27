import Foundation

@resultBuilder
public struct TestCaseBuilder {
    public typealias Component = XCTestCase.Type

    public static func buildBlock(_ components: Component...) -> [Component] {
        components
    }

    public static func buildOptional(_ component: Component?) -> [Component] {
        [component].compactMap { $0 }
    }

    public static func buildEither(first component: Component) -> [Component] {
        [component]
    }

    public static func buildEither(second component: Component) -> [Component] {
        [component]
    }

    public static func buildLimitedAvailability(_ component: Component) -> [Component] {
        [component]
    }

    public static func buildArray(_ components: [Component]) -> [Component] {
        components
    }
}
