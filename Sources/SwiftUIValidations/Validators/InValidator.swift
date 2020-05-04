//
//  InValidator.swift
//  
//
//  Created by Michael Housh on 5/2/20.
//

import Foundation

extension Validator where T: Equatable {
    /// Validates whether an item is contained in the supplied array.
    ///
    ///     let validator = Validator<String>.in("foo", "bar")
    ///
    /// - errorText: `in ("foo", "bar")`
    /// - inverseErrorText: `not in ("foo", "bar")`
    public static func `in`(_ array: T...) -> Validator<T> {
        return .in(array)
    }

    /// Validates whether an item is contained in the supplied array.
    ///
    ///     let validator = Validator<String>.in(["foo", "bar"])
    ///
    /// - errorText: `in ("foo", "bar")`
    /// - inverseErrorText: `not in ("foo", "bar")`
    public static func `in`(_ array: [T]) -> Validator<T> {
        return InValidator(array).validator()
    }
}

// MARK: Private
/// Validates whether an item is contained in the supplied array.
private struct InValidator<T>: ValidatorType where T: Equatable {
    /// See `ValidatorType`.
    public var errorText: String {
        let allJoined = array.map { "\($0)" }.joined(separator: ", ")
        return "in (\(allJoined))"
    }

    /// Array to check against.
    let array: [T]

    /// Creates a new `InValidator`.
    public init(_ array: [T]) {
        self.array = array
    }

    /// See `Validator`.
    public func validate(_ item: T) throws {
        guard array.contains(item) else {
            throw BasicValidationError(errorText)
        }
    }
}
