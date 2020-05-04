//
//  ValidationError.swift
//  
//
//  Created by Michael Housh on 5/2/20.
//

import Foundation

/// Representation of errors thrown from `Validator`'s.
public protocol ValidationError: Error {

    /// Failed validation error's.
    var errors: [String] { get }
}

/// A concrete `ValidationError`.
public struct BasicValidationError: ValidationError {

    public var errors: [String]

    /// Create a new error.
    ///
    /// - Parameters:
    ///     - errors: The validation error texts.
    init(_ errors: [String]) {
        self.errors = errors
    }

    /// Create a new error.
    ///
    /// - Parameters:
    ///     - error: The validation error text.
    init(_ error: String) {
        self.errors = [error]
    }

}
