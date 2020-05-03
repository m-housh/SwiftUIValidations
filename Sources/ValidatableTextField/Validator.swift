//
//  Validator.swift
//  
//
//  Created by Michael Housh on 4/29/20.
//

import Foundation

public struct Validator<T> {

    let errorText: String
    let inverseErrorText: String

    private let closure: (T) throws -> ()

    init(errorText: String, inverseErrorText: String, _ closure: @escaping (T) throws -> ()) {
        self.errorText = errorText
        self.inverseErrorText = inverseErrorText
        self.closure = closure
    }

    func  validate(_ data: T) throws {
        try closure(data)
    }
}
