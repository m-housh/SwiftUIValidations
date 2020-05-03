//
//  NotValidator.swift
//  
//
//  Created by Michael Housh on 5/2/20.
//

import Foundation

/// Adds the inverse of a validator using `!`.
///
///     let notEmpty: Validator<String> = !.empty
///
public prefix func !<T> (rhs: Validator<T>) -> Validator<T> {
    NotValidator(base: rhs).validator()
}

// MARK: - Private
/// Adds the inverse of a validator using `!`.
private struct NotValidator<T>: ValidatorType {

    typealias ValidationData = T

    let base: Validator<T>

    var errorText: String {
        "\(base.inverseErrorText)"
    }

    func validate(_ data: T) throws {
        var error: ValidationError?
        do {
            try base.validate(data)
        } catch let verror as ValidationError {
            error = verror
        }
        guard error != nil else {
            throw BasicValidationError([errorText])
        }
    }
}
