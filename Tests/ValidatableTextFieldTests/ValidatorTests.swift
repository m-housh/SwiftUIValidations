//
//  ValidatorTests.swift
//  
//
//  Created by Michael Housh on 4/29/20.
//

import XCTest
@testable import ValidatableTextField

final class ValidatorTests: XCTestCase {

    func test_Validator_combined_with_other() {
        let validator = Validator<String>.empty
            .combined(with: Validators<String>().notEmpty)

        XCTAssertEqual(validator.errors.count, 2)
        let result = validator.validate("foo")
        XCTAssert(result.isValid)
        let errorResult = validator.validate("")
        XCTAssertFalse(errorResult.isValid)
        XCTAssertEqual(errorResult.errors.count, 1)

    }

    func test_Validator_combined_with_other_using_Validators_keyPath() {
        let validator = Validator<String>.empty
            .combined(with: \.notEmpty)

        XCTAssertEqual(validator.errors.count, 2)
        let result = validator.validate("foo")
        XCTAssert(result.isValid)
        let errorResult = validator.validate("")
        XCTAssertFalse(errorResult.isValid)
        XCTAssertEqual(errorResult.errors.count, 1)
    }

    func test_Validator_combined_with_other_precedence() {

        let before = Validator<String>.empty
            .combined(with: \.notEmpty, evaluate: .before)
        XCTAssertEqual(before.errors.first, "Required")
        XCTAssertEqual(before.errors.last, "")

        let after = Validator<String>.empty
            .combined(with: \.notEmpty, evaluate: .after)
        XCTAssertEqual(after.errors.first, "")
        XCTAssertEqual(after.errors.last, "Required")
    }

    func test_ValidatorResult_combined_with_other() {
        let validator = Validators<String>().notEmpty.combined(with: \.notEmpty)
        let result = validator.validate("")
        XCTAssertEqual(result.errors.count, 2)
        XCTAssertEqual(result.errors.first, "Required")
        XCTAssertEqual(result.errors.last, "Required")

    }
}
