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

    var inverseReadable: String { get }

    func validate(_ data: ValidationData) throws -> ()
}

extension ValidatorType {

    public var inverseReadable: String {
        "Not \(validatorReadable.lowercased())"
    }
}

extension ValidatorType {

    public func validator() -> Validator<ValidationData> {
        Validator(readable: validatorReadable, inverseReadable: inverseReadable, validate)
    }
}
