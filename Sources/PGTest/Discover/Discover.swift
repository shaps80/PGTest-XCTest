import Foundation

//public func discoverTests() -> [(String, Selector)] {
//    let expectedClassCount = objc_getClassList(nil, 0)
//    let allClasses = UnsafeMutablePointer<AnyClass?>.allocate(capacity: Int(expectedClassCount))
//
//    let autoreleasingAllClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(allClasses)
//    let actualClassCount: Int32 = objc_getClassList(autoreleasingAllClasses, expectedClassCount)
//
//    var tests: [(String, Selector)] = []
//
//    for i in 0 ..< actualClassCount {
//        if let classType: AnyClass = allClasses[Int(i)],
//           class_getSuperclass(classType) == XCTestCase.self,
//           let testCase = classType as? XCTestCase.Type {
//
//            var methodCount: UInt32 = 0
//
//            if let methodList = class_copyMethodList(testCase, &methodCount) {
//                for i in 0..<Int(methodCount) {
//                    let selector = method_getName(methodList[i])
//                    if selector.description.hasPrefix("test") {
//                        tests.append(("\(selector)", selector))
//                    }
//                }
//            }
//
//            let types = "@@:"
//            let block: @convention(block) (XCTestCase.Type) -> NSArray = { obj in
//                NSArray(array: tests.map { [$0.0, $0.1] })
//            }
//            let imp = imp_implementationWithBlock(unsafeBitCast(block, to: XCTestCase.self))
//
//            if let meta = object_getClass(testCase) {
//                class_addMethod(meta, Selector(("allTests")), imp, types)
//                testCase.perform(Selector(("allTests")))
//            }
//        }
//    }
//
//    allClasses.deallocate()
//    return tests
//}
