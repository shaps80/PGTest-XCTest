import Foundation

public typealias DescriptionMethod = @convention(c) (XCTestCase) -> () -> Void

public func discoverTests() -> [(String, DescriptionMethod)] {
    let expectedClassCount = objc_getClassList(nil, 0)
    let allClasses = UnsafeMutablePointer<AnyClass?>.allocate(capacity: Int(expectedClassCount))

    let autoreleasingAllClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(allClasses)
    let actualClassCount: Int32 = objc_getClassList(autoreleasingAllClasses, expectedClassCount)

    var tests: [(String, DescriptionMethod)] = []

    for i in 0 ..< actualClassCount {
        if let classType: AnyClass = allClasses[Int(i)],
           class_getSuperclass(classType) == XCTestCase.self,
           let testCase = classType as? XCTestCase.Type {

            var methodCount: UInt32 = 0

            if let methodList = class_copyMethodList(testCase, &methodCount) {
                for i in 0..<Int(methodCount) {
                    let selector = method_getName(methodList[i])
                    if selector.description.hasPrefix("test"), let method = class_getInstanceMethod(testCase, selector) {
                        let imp = method_getImplementation(method)
                        let closure = unsafeBitCast(imp, to: DescriptionMethod.self)
                        tests.append(("\(selector)", closure))
                    }
                }
            }
        }
    }

    allClasses.deallocate()
    return tests
}
