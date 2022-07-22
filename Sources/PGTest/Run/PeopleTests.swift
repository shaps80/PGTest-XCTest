import Foundation

struct Person {
    let name: String
    let age: Int
}

final class PeopleTests: XCTestCase {
    func testNameIsCaseSensitive() {
        let person = Person(name: "shaps", age: 0)
        sleep(1)
        XCTAssertEqual(person.name, "shaps")
    }
    
    func testAgeIsCorrect() {
        let person = Person(name: "", age: 4)
        sleep(1)
        XCTAssertEqual(person.age, 41)
    }

    func testNameIsCaseSens2itive() {
        let person = Person(name: "shaps", age: 0)
        sleep(1)
        XCTAssertEqual(person.name, "shaps")
    }

    func testNameIsCase4Sensitive() {
        let person = Person(name: "shaps", age: 0)
        sleep(1)
        XCTAssertEqual(person.name, "shaps")
    }

    func testAgeIsCo2rrect() {
        let person = Person(name: "", age: 4)
        XCTAssertEqual(person.age, 41)
    }

    func testNameI45sCaseSensitive() {
        let person = Person(name: "shaps", age: 0)
        XCTAssertEqual(person.name, "shaps")
    }

    func testAgeIsCorr5ect() {
        let person = Person(name: "", age: 4)
        XCTAssertEqual(person.age, 41)
    }
    func testNameIsCaseSensi8tive() {
        let person = Person(name: "shaps", age: 0)
        XCTAssertEqual(person.name, "shaps")
    }

    func testAgeIsCorr8ect() {
        let person = Person(name: "", age: 4)
        XCTAssertEqual(person.age, 41)
    }
}
