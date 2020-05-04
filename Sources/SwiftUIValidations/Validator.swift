//
//  Validator.swift
//  
//
//  Created by Michael Housh on 4/29/20.
//

import Foundation

public struct Validator<T> {

    /// The error text for the validator, used by operators.
    let errorText: String

    /// The inverse error text for the validator, used by the `!` operator.
    let inverseErrorText: String

    /// The validation method.
    private let closure: (T) throws -> Void

    /// Create a new validator.
    ///
    /// - Parameters:
    ///     - errorText: The error text for the validator.
    ///     - inverseErrorText: The inverse error text for the validator, used by the `!` operator.
    ///     - closure: The method used to validate the data. Throwing a`ValidationError` on failure to validate.
    public init(errorText: String, inverseErrorText: String, _ closure: @escaping (T) throws -> Void) {
        self.errorText = errorText
        self.inverseErrorText = inverseErrorText
        self.closure = closure
    }

    /// Validate an item.
    ///
    /// - Parameters:
    ///     - data: The item to validate.
    ///
    /// - Throws: ValidationError: When validation fails.
    public func validate(_ data: T) throws {
        try closure(data)
    }
}
