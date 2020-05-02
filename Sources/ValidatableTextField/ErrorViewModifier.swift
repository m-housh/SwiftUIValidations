//
//  ErrorViewModifier.swift
//  
//
//  Created by Michael Housh on 4/29/20.
//

import Foundation
import SwiftUI
import Combine

struct ErrorViewModifier<Value>: ViewModifier {

    /// The value to validate.
    @Binding var value: Value

    /// Whether we should validate the value or not.
    @Binding var shouldEvaluate: Bool

    /// The current errors from validation.
    @State private var errors: [String] = []

    /// The validator used to validate the value.
    private let validator: Validator<Value>

    // Used for inspection testing.
    internal var didAppear: ((Self.Body) -> Void)?

    /// Create a new error modifier.
    ///
    /// - Parameters:
    ///     - value: The value to evaluate.
    ///     - shouldEvaluate: A binding that tells us when it's ok to evaluate the value.
    ///     - validator: The validator for the value.
    init(
        value: Binding<Value>,
        shouldEvaluate: Binding<Bool>,
        validator: Validator<Value>
    ) {
        self._value = value
        self._shouldEvaluate = shouldEvaluate
        self.validator = validator
    }

    /// Create a new error modifier.
    ///
    /// - Parameters:
    ///     - errors: The error text(s) to display on failed validation.
    ///     - value: The value to evaluate.
    ///     - shouldEvaluate: A binding that tells us when it's ok to evaluate the value.
    ///     - validate: A method to validate the value.
    init(
        errors: [String],
        value: Binding<Value>,
        shouldEvaluate: Binding<Bool> = .constant(true),
        validate: @escaping (Value) -> Bool
    ) {
        self._value = value
        self._shouldEvaluate = shouldEvaluate
        self.validator = .init(errors: errors, validate)
    }

    func body(content: Content) -> some View {
        VStack(alignment: .leading) {
            content
            ForEach(errors, id: \.self) { errorText in
                Text(errorText)
                    .font(.callout)
                    .foregroundColor(.red)
            }
        }
        .onReceive(errorUpdate) { self.errors = $0 }
        .onAppear { self.didAppear?(self.body(content: content)) }
    }

    private var errorUpdate: AnyPublisher<[String], Never> {
        Just(value)
            .compactMap { value in
                guard self.shouldEvaluate else { return nil }
                let result = self.validator.validate(value)
                guard !result.isValid else { return [] }
                guard !result.errors.isEmpty else { return nil }
                return result.errors
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}

extension View {

    /// Add an error modifier / validation to a view.
    ///
    /// - Parameters:
    ///     - errors: The error text(s) to display on failed validation.
    ///     - value: The value to evaluate.
    ///     - shouldEvaluate: A binding that tells us when it's ok to evaluate the value.
    ///     - validate: A method to validate the value.
    public func errorModifer<V>(
        errors: [String],
        value: Binding<V>,
        shouldEvaluate: Binding<Bool> = .constant(true),
        validator: @escaping (V) -> Bool
    ) -> some View {
        self.modifier(
            ErrorViewModifier(
                errors: errors,
                value: value,
                shouldEvaluate: shouldEvaluate,
                validate: validator
            )
        )
    }

    /// Add an error modifier / validation to a view.
    ///
    /// - Parameters:
    ///     - value: The value to evaluate.
    ///     - shouldEvaluate: A binding that tells us when it's ok to evaluate the value.
    ///     - keyPath: A key path on `Validators` to derive the validation method from.
    public func errorModifier<V>(
        value: Binding<V>,
        shouldEvaluate: Binding<Bool> = .constant(true),
        validator keyPaths: KeyPath<Validators<V>, Validator<V>>...
    ) -> some View {
        self.modifier(
            ErrorViewModifier(
                value: value,
                shouldEvaluate: shouldEvaluate,
                validator: keyPaths.validator()
            )
        )
    }

    /// Add an error modifier / validation to a view.
    ///
    /// - Parameters:
    ///     - value: The value to evaluate.
    ///     - shouldEvaluate: A binding that tells us when it's ok to evaluate the value.
    ///     - validator: A `Validator` used to validate the value.
    public func errorModifier<V>(
        value: Binding<V>,
        shouldEvaluate: Binding<Bool> = .constant(true),
        validator: Validator<V>...
    ) -> some View {
        self.modifier(
            ErrorViewModifier(
                value: value,
                shouldEvaluate: shouldEvaluate,
                validator: validator.validator()
            )
        )
    }
}

internal extension Array {
    func validator<V>() -> Validator<V> where Element == Validator<V> {
        reduce(Validator<V>.empty, { $0.combined(with: $1) })
    }

    func validator<V>() -> Validator<V> where Element == KeyPath<Validators<V>, Validator<V>> {
        map({ Validators<V>.validator(for: $0) }).validator()
    }
}
