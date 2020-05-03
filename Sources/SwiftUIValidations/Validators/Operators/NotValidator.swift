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
public prefix func !<T>(rhs: Validator<T>) -> Validator<T> {
    NotValidator(_validator: rhs).validator()
}

// MARK: - Private
/// Adds the inverse of a validator using `!`.
fileprivate struct NotValidator<T>: ValidatorType {

    typealias ValidationData = T

    let _validator: Validator<T>

    var errorText: String {
        "\(_validator.inverseErrorText)"
    }

    func validate(_ data: T) throws {
        var error: ValidationError?
        do {
            try _validator.validate(data)
        } catch let verror as ValidationError {
            error = verror
        }
        guard error != nil else {
            throw BasicValidationError([errorText])
        }
    }
}
