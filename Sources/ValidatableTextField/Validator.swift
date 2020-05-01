//
//  Validator.swift
//  
//
//  Created by Michael Housh on 4/29/20.
//

import Foundation

public protocol ValidationResultRepresentable {

    /// Whether the validation was successful.
    var isValid: Bool { get set }

    /// Error strings of failed validations.
    var errors: [String] { get set }

    /// Combine a result with another result.
    func combined(with other: ValidationResultRepresentable) -> ValidationResultRepresentable
}

public struct Validator<Type> {

    /// Called to validate an item and return a `ValidationResult` based on the result.
    private let validator: ((Type) -> Bool)?

    /// Used when we're combined with another validator.
    private let _validate: ((Type) -> ValidationResultRepresentable)?

    public let errors: [String]

    public init(errorText: String, _ validate: @escaping (Type) -> Bool) {
        self.validator = validate
        self.errors = [errorText]
        self._validate = nil
    }

    public init(errors: [String], _ validate: @escaping (Type) -> Bool) {
        self.errors = errors
        self.validator = validate
        self._validate = nil
    }

    public func validate(_ item: Type) -> ValidationResultRepresentable {
        guard let strongValidate = self._validate else {
            guard self.validator!(item) else {
                return ValidationResult(isValid: false, errors: errors)
            }
            return ValidationResult(isValid: true)
        }
        return strongValidate(item)
    }

    public static var empty: Validator<Type> {
        Validator(errorText: "", { _ in return true })
    }
}

// MARK: - Combine
extension Validator {

    public enum EvaluatePrecedence {
        case before, after
    }

    private init(lhs: Validator<Type>, rhs: Validator<Type>) {
        self.errors = lhs.errors + rhs.errors
        self.validator = nil
        self._validate = { lhs.validate($0).combined(with: rhs.validate($0)) }
    }

    public func combined(with other: Validator<Type>, evalute precedence: EvaluatePrecedence = .before) -> Validator<Type> {
        switch precedence {
        case .before: return .init(lhs: other, rhs: self)
        case .after: return .init(lhs: self, rhs: other)
        }
    }

    public func combined(with keyPath: KeyPath<Validators<Type>, Validator<Type>>, evaluate precedence: EvaluatePrecedence = .before) -> Validator<Type> {
        return combined(with: Validators<Type>()[keyPath: keyPath], evalute: precedence)
    }
}

struct ValidationResult: ValidationResultRepresentable {

    var isValid: Bool
    var errors: [String]

    init(isValid: Bool, errors: [String] = []) {
        self.isValid = isValid
        self.errors = errors
    }

    func combined(with other: ValidationResultRepresentable) -> ValidationResultRepresentable {
        var result = self
        if !other.isValid {
            result.isValid = false
            result.errors += other.errors
        }
        return result
    }
}
