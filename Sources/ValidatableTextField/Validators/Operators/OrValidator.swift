//
//  OrValidator.swift
//  
//
//  Created by Michael Housh on 5/2/20.
//

import Foundation

/// Combines validators using `or`, `||`.
///
///     let validator: Validator<String> = .empty || .in("foo", "bar")
///
public func ||<T>(lhs: Validator<T>, rhs: Validator<T>) -> Validator<T> {
    OrValidator(lhs: lhs, rhs: rhs).validator()
}

// MARK: - Private
/// Combines validators using `or`, `||`.
fileprivate struct OrValidator<T>: ValidatorType {

    typealias ValidationData = T

    let lhs: Validator<T>
    let rhs: Validator<T>

    var errorText: String {
        "\(lhs.errorText) or is \(rhs.errorText)"
    }

    func validate(_ data: T) throws {
        do {
            try lhs.validate(data)
        } catch let leftError as ValidationError {
            do {
                try rhs.validate(data)
            } catch let rightError as ValidationError {
                throw OrValidationError(lhsError: leftError, rhsError: rightError)
            }
        }
    }
}

/// Parses errors for `OrValidator`.
fileprivate struct OrValidationError: ValidationError {


    let lhsError: ValidationError
    let rhsError: ValidationError

    var errors: [String] { lhsError.errors + rhsError.errors }
}
