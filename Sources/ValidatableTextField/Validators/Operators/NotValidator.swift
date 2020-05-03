//
//  NotValidator.swift
//  
//
//  Created by Michael Housh on 5/2/20.
//

import Foundation

public prefix func !<T>(rhs: Validator<T>) -> Validator<T> {
    NotValidator(_validator: rhs).validator()
}

fileprivate struct NotValidator<T>: ValidatorType {

    typealias ValidationData = T

    let _validator: Validator<T>

    var validatorReadable: String {
        "\(_validator.inverseReadable)"
    }

    func validate(_ data: T) throws {
        var error: ValidationError?
        do {
            try _validator.validate(data)
        } catch let verror as ValidationError {
            error = verror
        }
        guard error != nil else {
            throw BasicValidationError([validatorReadable])
        }
    }
}
