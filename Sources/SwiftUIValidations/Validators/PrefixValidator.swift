//
//  PrefixValidator.swift
//  
//
//  Created by Michael Housh on 5/3/20.
//

import Foundation

extension Validator {

    /// Add a prefix string to a validator.
    ///
    ///     let validator: Validator<String> = .prefix("Required: ", .email)
    ///     // The error text would be "Required: invalid email"
    ///
    ///
    /// - Parameters:
    ///     - prefix: The prefix string to apply to valldation errors.
    ///     - validator: The validator to apply the prefix to.
    public static func prefix(_ prefix: String, _ validator: Validator<T>) -> Validator<T> {
        PrefixedValidator(prefix: prefix, base: validator).validator()
    }

    /// Add a prefix string to a validator.
    ///
    ///     let validator: Validator<String?> = .prefix("Required: ") {
    ///         .email
    ///     }
    ///     // The error text would be "Required: invalid email"
    ///
    ///
    /// - Parameters:
    ///     - prefix: The prefix string to apply to valldation errors.
    ///     - validator: A trailing closure that supplies the validator to apply the prefix to.
    public static func prefix(_ prefix: String, _ validator: @escaping () -> Validator<T>) -> Validator<T> {
        PrefixedValidator(prefix: prefix, base: validator()).validator()
    }
}

private struct PrefixedValidator<T>: ValidatorType {

    typealias ValidationData = T

    let prefix: String
    let base: Validator<T>

    var errorText: String {
        "\(prefix) \(base.errorText)"
    }

    var inverseErrorText: String {
        "\(prefix) \(base.inverseErrorText)"
    }

    func validate(_ data: T) throws {
        do {
            try base.validate(data)
        } catch let validationError as ValidationError {
            let prefixedErrors = validationError.errors.map {
                "\(prefix)\($0)"
            }
            throw BasicValidationError(prefixedErrors)
        }
    }
}
