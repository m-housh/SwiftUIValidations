//
//  ValidatorType.swift
//  
//
//  Created by Michael Housh on 5/2/20.
//

import Foundation

public protocol ValidatorType {

    associatedtype ValidationData

    var validatorReadable: String { get }

    func validate(_ data: ValidationData) -> Bool
}

extension ValidatorType {

    public func validator() -> Validator<ValidationData> {
        Validator(errorText: validatorReadable, validate)
    }
}
