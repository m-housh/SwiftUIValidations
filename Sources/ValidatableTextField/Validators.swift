//
//  Validators.swift
//  
//
//  Created by Michael Housh on 4/29/20.
//

import Foundation

/// A namespace for validators to be added to.
public struct Validators<T> {
    public init() { }
}

extension Validators where T == String {

    public var notEmpty: Validator<String> {
        Validator(errorText: "Required") { (string: String) -> Bool in
            let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
            return !trimmed.isEmpty
        }
    }
}
