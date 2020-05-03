//
//  File.swift
//  
//
//  Created by Michael Housh on 5/2/20.
//

import Foundation

extension Validator where T == String {

    /// Validates an email address.
    ///
    ///     let validator = Validator<String>.email
    ///
    public static var email: Validator<String> {
        EmailValidator().validator()
    }
}

// MARK: - Private
/// Validates an email address.
fileprivate struct EmailValidator: ValidatorType {

    var errorText: String { "invalid email" }

    var inverseErrorText: String { "valid email" }

    init() { }

    func validate(_ data: String) throws {
        guard
            let range = data.range(of: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}", options: [.regularExpression, .caseInsensitive]),
            range.lowerBound == data.startIndex && range.upperBound == data.endIndex
        else {
            throw BasicValidationError(errorText)
        }
    }
}
