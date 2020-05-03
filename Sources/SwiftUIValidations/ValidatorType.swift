//
//  ValidatorType.swift
//  
//
//  Created by Michael Housh on 5/2/20.
//

import Foundation

/// A type that can produce a `Validator`.
public protocol ValidatorType {

    /// The data type that it can validate.
    associatedtype ValidationData

    /// The error text for the validator.
    var errorText: String { get }

    /// The inverse error text, used with the `!` operator.
    var inverseErrorText: String { get }

    /// The method that validates the `ValidationData` type.
    func validate(_ data: ValidationData) throws
}

extension ValidatorType {

    public var inverseErrorText: String {
        "not \(errorText.lowercased())"
    }
}

extension ValidatorType {

    /// Creates a validator for this `ValidatorType`
    public func validator() -> Validator<ValidationData> {
        Validator(errorText: errorText, inverseErrorText: inverseErrorText, validate)
    }
}
