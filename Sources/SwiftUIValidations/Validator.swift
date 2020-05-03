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

    init(errorText: String, inverseErrorText: String, _ closure: @escaping (T) throws -> Void) {
        self.errorText = errorText
        self.inverseErrorText = inverseErrorText
        self.closure = closure
    }

    func validate(_ data: T, errorPrefix: String = "") throws {
        do {
            try closure(data)
        } catch let error as ValidationError {
            guard !errorPrefix.isEmpty else {
                throw error
            }
            let errors = error.errors.map { "\(errorPrefix) \($0)" }
            throw BasicValidationError(errors)
        }
    }
}
