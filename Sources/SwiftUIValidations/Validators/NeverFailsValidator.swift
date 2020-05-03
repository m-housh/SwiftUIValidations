//
//  File.swift
//  
//
//  Created by Michael Housh on 5/2/20.
//

import Foundation

extension Validator {

    /// A validator that always succeeds.  Can be useful when `reduce`ing validators.
    ///
    ///         let validators: [Validator<String>] = [.alphanumerics, .email]
    ///         let validator: Validator<String> = validators.reduce(.neverFails, { $0 && $1 })
    ///
    ///
    public static var neverFails: Validator<T> {
        NeverFailsValidator().validator()
    }
}

fileprivate struct NeverFailsValidator<T>: ValidatorType {

    typealias ValidationData = T

    var errorText: String { "Never fails" }
    var inverseErrorText: String { "Never fails" }

    func validate(_ data: T) throws {
        return
    }
}
