//
//  ValidatorTests.swift
//  
//
//  Created by Michael Housh on 4/29/20.
//

import XCTest
@testable import SwiftUIValidations

extension Validator where T == String {

    static var isFoo: Validator<T> {
        Validator(errorText: "Is foo", inverseErrorText: "Is not foo") { string in
            guard string == "foo" else {
                throw BasicValidationError("Is not foo")
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
        XCTAssertEqual(errors.last, "invalid email")
    }

    func test_NeverFails_Validator() {
        let validator = Validator<String>.neverFails
        XCTAssertNoThrow(try validator.validate(""))
    }

    func test_Count_Validator_with_min_range() throws {
        let validator = Validator<String>.count(3...)
        XCTAssertNoThrow(try validator.validate("123"))

        try validateErrors(value: "12", validator: validator) { errors in
            XCTAssertEqual(errors.count, 1)
            XCTAssertEqual(errors.first, "count: at least 3 characters")
        }
    }

    func test_Count_Validator_with_min_and_max_range() throws {
        let validator = Validator<String>.count(3...5)
        XCTAssertNoThrow(try validator.validate("123"))

        try validateErrors(value: "12", validator: validator) { errors in
            XCTAssertEqual(errors.count, 1)
            XCTAssertEqual(errors.first, "count: between 3 and 5 characters")
        }

        try validateErrors(value: "123456", validator: validator) { errors in
            XCTAssertEqual(errors.count, 1)
            XCTAssertEqual(errors.first, "count: between 3 and 5 characters")
        }
    }

    func test_Count_Validator_with_upper_range() throws {
        let validator = Validator<String>.count(...5)
        XCTAssertNoThrow(try validator.validate("12345"))
        XCTAssertNoThrow(try validator.validate("1234"))
        XCTAssertNoThrow(try validator.validate("123"))
        XCTAssertNoThrow(try validator.validate("12"))
        XCTAssertNoThrow(try validator.validate("1"))
        XCTAssertNoThrow(try validator.validate(""))

        try validateErrors(value: "123456", validator: validator) { errors in
            XCTAssertEqual(errors.count, 1)
            XCTAssertEqual(errors.first, "count: at most 5 characters")
        }
    }

    func test_Count_Validator_with_range() throws {
        let validator = Validator<String>.count(3..<5)
        XCTAssertNoThrow(try validator.validate("123"))

        try validateErrors(value: "12", validator: validator) { errors in
            XCTAssertEqual(errors.count, 1)
            XCTAssertEqual(errors.first, "count: between 3 and 4 characters")
        }

        try validateErrors(value: "12345", validator: validator) { errors in
            XCTAssertEqual(errors.count, 1)
            XCTAssertEqual(errors.first, "count: between 3 and 4 characters")
        }
    }

    func test_Count_Validator_error_text_with_array() throws {
        let validator = Validator<[String]>.count(2...5)
        XCTAssertNoThrow(try validator.validate(["foo", "bar"]))

        try validateErrors(value: ["foo"], validator: validator) { errors in
            XCTAssertEqual(errors.count, 1)
            XCTAssertEqual(errors.first, "count: between 2 and 5 items")
        }
    }

    func test_Count_Validator_error_text_with_array_and_one_max() throws {
        let validator = Validator<[String]>.count(0...1)
        XCTAssertNoThrow(try validator.validate(["foo"]))

        try validateErrors(value: ["foo", "bar"], validator: validator) { errors in
            XCTAssertEqual(errors.count, 1)
            XCTAssertEqual(errors.first, "count: between 0 and 1 item")
        }
    }

    func test_Count_Validator_error_text_with_string_and_one_max() throws {
        let validator = Validator<String>.count(0...1)
        XCTAssertNoThrow(try validator.validate("f"))

        try validateErrors(value: "foo", validator: validator) { errors in
            XCTAssertEqual(errors.count, 1)
            XCTAssertEqual(errors.first, "count: between 0 and 1 character")
        }
    }

    func test_Range_Validator_with_min_range() throws {
        let validator = Validator<Int>.range(3...)
        XCTAssertNoThrow(try validator.validate(3))

        try validateErrors(value: 1, validator: validator) { errors in
            XCTAssertEqual(errors.count, 1)
            XCTAssertEqual(errors.first, "range: at least 3")
        }
    }

    func test_Range_Validator_with_min_and_max_range() throws {
        let validator = Validator<Int>.range(3...5)
        XCTAssertNoThrow(try validator.validate(4))

        try validateErrors(value: 10, validator: validator) { errors in
            XCTAssertEqual(errors.count, 1)
            XCTAssertEqual(errors.first, "range: between 3 and 5")
        }

        try validateErrors(value: 1, validator: validator) { errors in
            XCTAssertEqual(errors.count, 1)
            XCTAssertEqual(errors.first, "range: between 3 and 5")
        }
    }

    func test_Range_Validator_with_upper_range() throws {
        let validator = Validator<Int>.range(...5)
        XCTAssertNoThrow(try validator.validate(5))
        XCTAssertNoThrow(try validator.validate(4))
        XCTAssertNoThrow(try validator.validate(3))
        XCTAssertNoThrow(try validator.validate(2))
        XCTAssertNoThrow(try validator.validate(1))
        XCTAssertNoThrow(try validator.validate(0))

        try validateErrors(value: 6, validator: validator) { errors in
            XCTAssertEqual(errors.count, 1)
            XCTAssertEqual(errors.first, "range: at most 5")
        }
    }

    func test_Range_Validator_with_range() throws {
        let validator = Validator<Int>.range(3..<5)
        XCTAssertNoThrow(try validator.validate(4))

        try validateErrors(value: 1, validator: validator) { errors in
            XCTAssertEqual(errors.count, 1)
            XCTAssertEqual(errors.first, "range: between 3 and 4")
        }

        try validateErrors(value: 5, validator: validator) { errors in
            XCTAssertEqual(errors.count, 1)
            XCTAssertEqual(errors.first, "range: between 3 and 4")
        }
    }

    func test_In_Validator() throws {
        let validator = Validator<String>.in("foo", "bar")
        XCTAssertNoThrow(try validator.validate("foo"))
        XCTAssertNoThrow(try validator.validate("bar"))

        try validateErrors(value: "not foo", validator: validator) { errors in
            XCTAssertEqual(errors.count, 1)
            XCTAssertEqual(errors.first, "in: (foo, bar)")
        }
    }

    func test_Alphanumerics_CharacterSet_Validator() throws {
        let validator = Validator<String>.alphanumeric
        XCTAssertNoThrow(try validator.validate("a"))
        XCTAssertNoThrow(try validator.validate("0"))

        try validateErrors(value: "_", validator: validator) { errors in
            XCTAssertEqual(errors.count, 1)
            XCTAssertEqual(errors.first!, "contains an invalid character: '_' (allowed: A-Z, a-z, 0-9)")
        }
    }

    func test_ASCII_CharacterSet_Validator() throws {
        let validator = Validator<String>.ascii
        XCTAssertNoThrow(try validator.validate("a"))
        XCTAssertNoThrow(try validator.validate("0"))

        let string = String("😂")
        try validateErrors(value: "\(string)", validator: validator) { errors in
            XCTAssertEqual(errors.count, 1)
            XCTAssertEqual(errors.first!, "contains an invalid character: '😂'")
        }
    }

    func test_CharacterSet_Addition_With_Other_Validator() throws {
        let validator = Validator<String>.characterSet(.alphanumerics + .whitespaces)
        XCTAssertNoThrow(try validator.validate("a"))
        XCTAssertNoThrow(try validator.validate("0"))
        XCTAssertNoThrow(try validator.validate("0 aa"))

        try validateErrors(value: "_", validator: validator) { errors in
            XCTAssertEqual(errors.count, 1)
            XCTAssertEqual(errors.first!, "contains an invalid character: '_' (allowed: whitespace, A-Z, a-z, 0-9)")
        }
    }

    func test_Nil_Validator_inverse() throws {
        let validator: Validator<Int?> = !.nil
        XCTAssertNoThrow(try validator.validate(1))

        try validateErrors(value: nil, validator: validator) { errors in
            XCTAssertEqual(errors.count, 1)
            XCTAssertEqual(errors.first, "not nil")
        }
    }

    func test_Nil_Validator() throws {
         let validator: Validator<Int?> = .nil
         XCTAssertNoThrow(try validator.validate(nil))

         try validateErrors(value: 1, validator: validator) { errors in
             XCTAssertEqual(errors.count, 1)
             XCTAssertEqual(errors.first, "nil")
         }
     }

    func test_NilIgnoring_Validator_combined_with_or_operator() throws {
        let validator1: Validator<String?> = .nil || .email
        let validator2: Validator<String?> = .email || .nil

        for validator in [validator1, validator2] {
            XCTAssertNoThrow(try validator.validate(nil))
            XCTAssertNoThrow(try validator.validate("foo@bar.com"))

            try validateErrors(value: "invalid email", validator: validator) { errors in
                XCTAssertEqual(errors.count, 2)
                XCTAssert(errors.contains("nil"))
                XCTAssert(errors.contains("invalid email"))

            }
        }
    }

    func test_NilIgnoring_Validator_combined_with_and_operator() throws {
        let validator1: Validator<String?> = !.nil && .email
        let validator2: Validator<String?> = .email && !.nil

        for validator in [validator1, validator2] {
            XCTAssertThrowsError(try validator.validate(nil))
            XCTAssertNoThrow(try validator.validate("foo@bar.com"))

            try validateErrors(value: "invalid email", validator: validator) { errors in
                XCTAssertEqual(errors.count, 1)
                XCTAssert(errors.contains("invalid email"))
            }
        }
    }

    func test_Validator_validate_with_error_prefix() throws {
        let validator: Validator<String> = .email

        try validateErrors(value: "invalid", validator: validator, errorPrefix: "Required:") { errors in
            XCTAssertEqual(errors.count, 1)
            XCTAssertEqual(errors.first, "Required: invalid email")
        }
    }

    func test_Url_Validator() throws {
        let validator: Validator<String> = .url
        XCTAssertNoThrow(try validator.validate("http://example.com"))

        try validateErrors(value: "invalid", validator: validator) { errors in
            XCTAssertEqual(errors.count, 1)
            XCTAssertEqual(errors.first, "invalid url")
        }
    }
}

// MARK: - Helpers
extension ValidatorTests {

    func validateErrors<T>(
        value: T, validator: Validator<T>,
        errorPrefix: String = "",
        _ callback: ([String]) -> Void) throws
    {
        do {
            try validator.validate(value, errorPrefix: errorPrefix)
        } catch let error as ValidationError {
            callback(error.errors)
        }
    }
}
