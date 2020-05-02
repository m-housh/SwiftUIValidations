//
//  File.swift
//  
//
//  Created by Michael Housh on 5/2/20.
//

import Foundation

extension Validator where T == String {

    public static var email: Validator<T> {
        EmailValidator().validator()
    }
}

fileprivate struct EmailValidator: ValidatorType {

    var validatorReadable: String { "Invalid email" }

    var inverseReadable: String { "Valid email" }

    init() { }

    func validate(_ data: String) throws {
        guard
            let range = data.range(of: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}", options: [.regularExpression, .caseInsensitive]),
            range.lowerBound == data.startIndex && range.upperBound == data.endIndex
        else {
            throw BasicValidationError(errors: [validatorReadable])
        }
    }
}
