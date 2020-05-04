//
//  EmptyValidator.swift
//  
//
//  Created by Michael Housh on 5/2/20.
//

import Foundation

extension Validator where T: Collection {

    /// Validates whether a collection is empty or not.
    ///
    ///         let validator = Validator<String>.empty
    ///
    /// - errorText: `empty`
    /// - inverseErrorText: `not empty`
    public static var empty: Validator<T> {
        EmptyValidator().validator()
    }
}

// MARK: - Private
/// Validates whether a collection is empty or not.
private struct EmptyValidator<T>: ValidatorType where T: Collection {

    typealias ValidationData = T

    var errorText: String { "empty" }
    var inverseErrorText: String { "not empty" }

    func validate(_ data: T) throws {
        guard data.isEmpty else {
            throw BasicValidationError(errorText)
        }
    }
}
