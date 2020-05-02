//
//  ValidatorTests.swift
//  
//
//  Created by Michael Housh on 4/29/20.
//

import XCTest
@testable import ValidatableTextField

extension Validator where T == String {

    static var isFoo: Validator<T> {
        Validator(readable: "Is foo", inverseReadable: "Is not foo") { string in
            guard string == "foo" else {
                throw BasicValidationError(errors: ["Is not foo"])
            }
        }
    }
}

final class ValidatorTests: XCTestCase {

    func test_Validator_combined_with_other() throws {
        let validator = !Validator<String>.empty && !Validator<String>.empty
        var errors: [String]!
        do {
            try validator.validate("")
        } catch let validationError as ValidationError {
            errors = validationError.errors
        }

        XCTAssertEqual(errors.count, 2)
        XCTAssertNoThrow(try validator.validate("foo"))

    }

    func test_OrValidator() throws {
        let validator = Validator<String>.isFoo || Validator<String>.email
        XCTAssertNoThrow(try validator.validate("foo"))
        XCTAssertNoThrow(try validator.validate("foo@bar.com"))

        var errors: [String]!
        do {
            try validator.validate("not foo or email")
        } catch let validationError as ValidationError {
            errors = validationError.errors
        }
        XCTAssertEqual(errors.count, 2)
        XCTAssertEqual(errors.first, "Is not foo")
        XCTAssertEqual(errors.last, "Invalid email")
    }

    func test_NeverFails_Validator() {
        let validator = Validator<String>.neverFails
        XCTAssertNoThrow(try validator.validate(""))
    }

//    func test_Validator_combined_with_other_using_Validators_keyPath() {
//        let validator = Validator<String>.empty
//            .combined(with: \.notEmpty)
//
//        XCTAssertEqual(validator.errors.count, 2)
//        let result = validator.validate("foo")
//        XCTAssert(result.isValid)
//        let errorResult = validator.validate("")
//        XCTAssertFalse(errorResult.isValid)
//        XCTAssertEqual(errorResult.errors.count, 1)
//    }
//
//    func test_Validator_combined_with_other_precedence() {
//
//        let before = Validator<String>.empty
//            .combined(with: \.notEmpty, evaluate: .before)
//        XCTAssertEqual(before.errors.first, "Required")
//        XCTAssertEqual(before.errors.last, "")
//
//        let after = Validator<String>.empty
//            .combined(with: \.notEmpty, evaluate: .after)
//        XCTAssertEqual(after.errors.first, "")
//        XCTAssertEqual(after.errors.last, "Required")
//    }
//
//    func test_ValidatorResult_combined_with_other() {
//        let validator = Validators<String>().notEmpty.combined(with: \.notEmpty)
//        let result = validator.validate("")
//        XCTAssertEqual(result.errors.count, 2)
//        XCTAssertEqual(result.errors.first, "Required")
//        XCTAssertEqual(result.errors.last, "Required")
//
//    }
}
