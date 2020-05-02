//
//  ValidationError.swift
//  
//
//  Created by Michael Housh on 5/2/20.
//

import Foundation

public protocol ValidationError: Error {
    var errors: [String] { get }
}

public struct BasicValidationError: ValidationError {

    public var errors: [String]

    init(errors: [String]) {
        self.errors = errors
    }

}
