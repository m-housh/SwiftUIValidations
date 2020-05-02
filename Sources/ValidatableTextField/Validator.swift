//
//  Validator.swift
//  
//
//  Created by Michael Housh on 4/29/20.
//

import Foundation

public struct Validator<T> {

    let readable: String
    let inverseReadable: String

    private let closure: (T) throws -> ()

    init(readable: String, inverseReadable: String, _ closure: @escaping (T) throws -> ()) {
        self.readable = readable
        self.inverseReadable = inverseReadable
        self.closure = closure
    }

    func  validate(_ data: T) throws {
        try closure(data)
    }
}
