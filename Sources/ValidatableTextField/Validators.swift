//
//  Validators.swift
//  
//
//  Created by Michael Housh on 4/29/20.
//

import Foundation

/// A namespace for validators to be added to.
public struct Validators<Type> {
    public init() { }

    static func validator(for keyPath: KeyPath<Validators<Type>, Validator<Type>>) -> Validator<Type> {
        Self()[keyPath: keyPath]
    }
}

extension Validators where Type == String {

    public var notEmpty: Validator<String> {
        Validator(errorText: "Required") { (string: String) -> Bool in
            let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
            return !trimmed.isEmpty
        }
    }
}
