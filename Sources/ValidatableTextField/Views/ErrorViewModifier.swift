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
            .tryCompactMap { value -> [String]? in
                guard self.shouldEvaluate else { return nil }
                do {
                    try self.validator.validate(value)
                    return [String]()
                } catch let error as ValidationError {
                    return error.errors
                }
            }
            .replaceError(with: [String]()) // unhandled error / didn't throw ValidationError
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
        value: Binding<V>,
        shouldEvaluate: Binding<Bool> = .constant(true),
        validator: @escaping () -> Validator<V>
    ) -> some View {
        self.modifier(
            ErrorViewModifier(
                value: value,
                shouldEvaluate: shouldEvaluate,
                validator: validator()
            )
        )
    }

    public func errorModifer<V>(
        value: Binding<V>,
        shouldEvaluate: Binding<Bool> = .constant(true),
        validator: Validator<V>
    ) -> some View {
        self.modifier(
            ErrorViewModifier(
                value: value,
                shouldEvaluate: shouldEvaluate,
                validator: validator
            )
        )
    }
}
