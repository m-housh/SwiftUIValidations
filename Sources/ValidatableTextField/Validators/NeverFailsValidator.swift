//
//  File.swift
//  
//
//  Created by Michael Housh on 5/2/20.
//

import Foundation

extension Validator {

    public static var neverFails: Validator<T> {
        NeverFailsValidator().validator()
    }
}

fileprivate struct NeverFailsValidator<T>: ValidatorType {

    typealias ValidationData = T

    var validatorReadable: String { "Never fails" }
    var inverseReadable: String { "Never fails" }

    func validate(_ data: T) throws {
        return
    }
}
