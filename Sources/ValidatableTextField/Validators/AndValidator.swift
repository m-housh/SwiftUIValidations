//
//  File.swift
//  
//
//  Created by Michael Housh on 5/2/20.
//

import Foundation

public func &&<T>(lhs: Validator<T>, rhs: Validator<T>) -> Validator<T> {
    AndValidator(lhs: lhs, rhs: rhs).validator()
}

fileprivate struct AndValidator<T>: ValidatorType {

    typealias ValidationData = T

    let lhs: Validator<T>
    let rhs: Validator<T>

    var validatorReadable: String {
        "\(lhs.readable) and is \(rhs.readable)"
    }

    func validate(_ data: T) throws {
        var leftError: ValidationError?
        do {
            try lhs.validate(data)
        } catch let lerror as ValidationError {
            leftError = lerror
        }

        var rightError: ValidationError?
        do {
            try rhs.validate(data)
        } catch let rerror as ValidationError{
            rightError = rerror
        }

        if leftError != nil || rightError != nil {
            throw AndValidationError(lhsError: leftError, rhsError: rightError)
        }
    }
}

fileprivate struct AndValidationError: ValidationError {

    let lhsError: ValidationError?
    let rhsError:ValidationError?

    var errors: [String] {
        var errors = [String]()
        if let left = lhsError {
            errors += left.errors
        }
        if let right = rhsError{
            errors += right.errors
        }
        return errors
    }
}
