//
//  CustomValidator.swift
//  
//
//  Created by Michael Housh on 5/3/20.
//

import Foundation

extension Validator {

    /// Wrap a supplied `Validator` with a custom error message.
    ///
    ///         let validator: Validator<String> = .custom("Required", !.empty)
    ///         /// The error text would be "Required"
    ///
    /// - Parameters:
    ///     - error: The text to repllace alll errors thrown with.
    ///     - inverseError: Optionalllly over-ride the inverse error text as well.
    ///     - validator: The validator to wrap and replace errors thrown with a custom message.
    public static func custom(_ error: String, inverseError: String? = nil, _ validator: Validator<T>) -> Validator<T> {
        CustomValidator(base: validator, errorText: error, inverseError: inverseError).validator()
    }

    /// Wrap a supplied `Validator` with a custom error message.
    ///
    ///         let validator: Validator<String> = .custom("Required") {
    ///             !.empty
    ///         }
    ///         /// The error text would be "Required"
    ///
    /// - Parameters:
    ///     - error: The text to repllace alll errors thrown with.
    ///     - inverseError: Optionalllly over-ride the inverse error text as well.
    ///     - validator: A traiiling closure that returns the validator to wrap and replace errors thrown with a custom message.
    public static func custom(_ error: String, inverseError: String? = nil, _ validator: @escaping () -> Validator<T>) -> Validator<T> {
        CustomValidator(base: validator(), errorText: error, inverseError: inverseError).validator()
    }
}

private struct CustomValidator<T>: ValidatorType {
    typealias ValidationData = T

    let base: Validator<T>
    let errorText: String
    let inverseError: String?

    var inverseErrorText: String {
        inverseError ?? base.inverseErrorText
    }

    func validate(_ data: T) throws {
        do {
            try base.validate(data)
        } catch let validationError as ValidationError {
            let errors = validationError.errors.map { _ in errorText }
            throw BasicValidationError(errors)
        }
    }
}
