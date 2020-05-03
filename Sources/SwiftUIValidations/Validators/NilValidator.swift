//
//  NilValidator.swift
//  
//
//  Created by Michael Housh on 5/3/20.
//

import Foundation

extension Validator where T: OptionalType {

    /// Validates that the data is `nil`. Combine with the not-operator `!` to validate that the data is not `nil`.
    ///
    ///     let validator: Validator<Int?> = !.nil
    ///
    public static var `nil`: Validator<T.WrappedType?> {
        return NilValidator(T.WrappedType.self).validator()
    }
}

/// Validates that the data is `nil`.
private struct NilValidator<T>: ValidatorType {

    typealias ValidationData = T?

    let errorText: String = "nil"
    let inverseErrorText: String = "not nil"

    /// Creates a new `NilValidator`.
    init(_ type: T.Type) {}

    /// See `Validator`.
    func validate(_ data: T?) throws {
        if data != nil {
            throw BasicValidationError(errorText)
        }
    }
}

public protocol OptionalType {
    associatedtype WrappedType
}

extension Optional: OptionalType {
    public typealias WrappedType = Wrapped
}
