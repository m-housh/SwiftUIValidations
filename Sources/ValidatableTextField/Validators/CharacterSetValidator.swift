//
//  CharacterSetValidator.swift
//  
//
//  Created by Michael Housh on 5/2/20.
//

import Foundation

extension Validator where T == String {

    /// Validates that all characters in a `String` are ASCII (bytes 0..<128).
    ///
    ///     let validator = Validator<String>.ascii
    ///
    public static var ascii: Validator<String> {
        return .characterSet(.ascii)
    }

    /// Validates that all characters in a `String` are alphanumeric (a-z,A-Z,0-9).
    ///
    ///     let validator = Validator<String>.alphanumeric
    ///
    public static var alphanumeric: Validator<String> {
        return .characterSet(.alphanumerics)
    }

    /// Validates that all characters in a `String` are in the supplied `CharacterSet`.
    ///
    ///     let validator = Validator<String>.characterSet(.alphanumerics + .whitespaces)
    ///
    public static func characterSet(_ characterSet: CharacterSet) -> Validator<String> {
        return CharacterSetValidator(characterSet).validator()
    }
}

/// Unions two character sets.
///
///     .characterSet(.alphanumerics + .whitespaces)
///
public func +(lhs: CharacterSet, rhs: CharacterSet) -> CharacterSet {
    return lhs.union(rhs)
}


// MARK: Private
/// Validates that a `String` contains characters in a given `CharacterSet`
fileprivate struct CharacterSetValidator: ValidatorType {

    /// `CharacterSet` to validate against.
    let characterSet: CharacterSet

    /// See `Validator`
    public var errorText: String {
        if characterSet.traits.count > 0 {
            let string = characterSet.traits.joined(separator: ", ")
            return "(allowed: \(string))"
        } else {
            return ""
        }
    }

    /// Creates a new `CharacterSetValidator`.
    init(_ characterSet: CharacterSet) {
        self.characterSet = characterSet
    }

    /// See `Validator`
    public func validate(_ s: String) throws {
        if let range = s.rangeOfCharacter(from: characterSet.inverted) {
            var reason = "Contains an invalid character: '\(s[range])'"
            if characterSet.traits.count > 0 {
                reason += " \(errorText)"
            }
            throw BasicValidationError(reason)
        }
    }
}

extension CharacterSet {
    /// ASCII (byte 0..<128) character set.
    fileprivate static var ascii: CharacterSet {
        var ascii: CharacterSet = .init()
        for i in 0..<128 {
            ascii.insert(Unicode.Scalar(i)!)
        }
        return ascii
    }
}


extension CharacterSet {
    /// Returns an array of strings describing the contents of this `CharacterSet`.
    fileprivate var traits: [String] {
        var desc: [String] = []
        if isSuperset(of: .newlines) {
            desc.append("newlines")
        }
        if isSuperset(of: .whitespaces) {
            desc.append("whitespace")
        }
        if isSuperset(of: .capitalizedLetters) {
            desc.append("A-Z")
        }
        if isSuperset(of: .lowercaseLetters) {
            desc.append("a-z")
        }
        if isSuperset(of: .decimalDigits) {
            desc.append("0-9")
        }
        return desc
    }
}
