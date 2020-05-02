//
//  EmptyValidator.swift
//  
//
//  Created by Michael Housh on 5/2/20.
//

import Foundation

extension Validator where T: Collection {

    public static var empty: Validator<T> {
        EmptyValidator().validator()
    }
}

fileprivate struct EmptyValidator<T>: ValidatorType where T: Collection {

    typealias ValidationData = T

    var validatorReadable: String { "Empty" }
    var inverseReadable: String { "Required" }

    func validate(_ data: T) throws {
        guard data.isEmpty else {
            throw BasicValidationError(errors: [(validatorReadable)])
        }
    }
}
