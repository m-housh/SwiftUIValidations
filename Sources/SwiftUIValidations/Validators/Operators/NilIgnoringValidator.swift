//
//  NilIgnoringValidator.swift
//  
//
//  Created by Michael Housh on 5/3/20.
//

import Foundation

/// Combines an optional and non-optional `Validator` using OR logic. The non-optional
/// validator will simply ignore `nil` values, assuming the other `Validator` handles them.
///
///     let validator: Validator<String?> = .nil || .email
///
public func ||<T> (lhs: Validator<T?>, rhs: Validator<T>) -> Validator<T?> {
    return lhs || NilIgnoringValidator(rhs).validator()
}

/// Combines an optional and non-optional `Validator` using OR logic. The non-optional
/// validator will simply ignore `nil` values, assuming the other `Validator` handles them.
///
///     let validator: Validator<String?> = .email || .nil
///
public func ||<T> (lhs: Validator<T>, rhs: Validator<T?>) -> Validator<T?> {
    return NilIgnoringValidator(lhs).validator() || rhs
}

/// Combines an optional and non-optional `Validator` using AND logic. The non-optional
/// validator will simply ignore `nil` values, assuming the other `Validator` handles them.
///
///     let validator: Validator<String?> = !.nil && .email
///
public func &&<T> (lhs: Validator<T?>, rhs: Validator<T>) -> Validator<T?> {
    return lhs && NilIgnoringValidator(rhs).validator()
}

/// Combines an optional and non-optional `Validator` using AND logic. The non-optional
/// validator will simply ignore `nil` values, assuming the other `Validator` handles them.
///
///     let validator: Validator<String?> = .email && !.nil
///
public func &&<T> (lhs: Validator<T>, rhs: Validator<T?>) -> Validator<T?> {
    return NilIgnoringValidator(lhs).validator() && rhs
}

// MARK: Private
/// A validator that ignores nil values.
fileprivate struct NilIgnoringValidator<T>: ValidatorType {

    /// right validator
    let base: Validator<T>

    /// See `ValidatorType`.
    public var errorText: String {
        return base.errorText
    }

    var inverseErrorText: String {
        base.inverseErrorText
    }

    /// Creates a new `NilIgnoringValidator`.
    init(_ base: Validator<T>) {
        self.base = base
    }

    /// See `ValidatorType`.
    func validate(_ data: T?) throws {
        if let data = data {
            try base.validate(data)
        }
    }
}
