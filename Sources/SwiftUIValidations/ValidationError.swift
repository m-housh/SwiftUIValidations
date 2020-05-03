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

    init(_ errors: [String]) {
        self.errors = errors
    }

    init(_ error: String) {
        self.errors = [error]
    }

}
