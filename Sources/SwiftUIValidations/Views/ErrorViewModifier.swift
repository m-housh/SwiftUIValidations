//
//  ErrorViewModifier.swift
//  
//
//  Created by Michael Housh on 4/29/20.
//

import Foundation
import SwiftUI
import Combine

struct ErrorViewModifier<Value, ErrorView>: ViewModifier where ErrorView: View {

    /// The value to validate.
    @Binding var value: Value

    /// Whether we should validate the value or not.
    @Binding var shouldEvaluate: Bool

    /// The current errors from validation.
    @State private var errors: [String] = []

    /// The validator used to validate the value.
    private let validator: Validator<Value>

    /// Generates the view for each error that is generated during validatiion.
    private let errorViewBuilder: ([String]) -> ErrorView

    /// The alignment for the `VStack` for the errors.
    private let alignment: HorizontalAlignment

    // Used for inspection testing.
    internal var didAppear: ((Self.Body) -> Void)?

    /// Create a new error modifier.
    ///
    /// - Parameters:
    ///     - value: The value to evaluate.
    ///     - shouldEvaluate: A binding that tells us when it's ok to evaluate the value.
    ///     - alignment: Alignment guide for the `VStack` that holds the content and errors.
    ///     - validator: The validator for the value.
    init(
        value: Binding<Value>,
        shouldEvaluate: Binding<Bool>,
        alignment: HorizontalAlignment = .leading,
        validator: Validator<Value>,
        @ViewBuilder errorView: @escaping ([String]) -> ErrorView
    ) {
        self._value = value
        self._shouldEvaluate = shouldEvaluate
        self.validator = validator
        self.errorViewBuilder = errorView
        self.alignment = alignment
    }

    func body(content: Content) -> some View {
        VStack(alignment: alignment) {
            content
            self.errorViewBuilder(errors)
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
    ///     - value: The value to evaluate.
    ///     - shouldEvaluate: A binding that tells us when it's ok to evaluate the value.
    ///     - alignment: Alignment guide for the `VStack` that holds the content and errors.
    ///     - validator: A `Validator`, used to validate the value.
    ///     - builder: A view builder for when errors are generated.
    public func errorModifer<V, E>(
        value: Binding<V>,
        shouldEvaluate: Binding<Bool> = .constant(true),
        alignment: HorizontalAlignment = .leading,
        validator: Validator<V>,
        @ViewBuilder _ builder: @escaping ([String]) -> E
    ) -> some View
        where E: View
    {
        self.modifier(
            ErrorViewModifier(
                value: value,
                shouldEvaluate: shouldEvaluate,
                alignment: alignment,
                validator: validator,
                errorView: builder
            )
        )
    }

    /// Add an error modifier / validation to a view, with a default error view builder.
    ///
    ///  - Note:
    ///     The default error view, which is called for each error generated during validation.
    ///     ``` swift
    ///     ForEach(errors, id: \.self) { error in
    ///         Text(error)
    ///             .font(.callout)
    ///             .foregroundColor(.red)
    ///     }
    ///     ```
    ///
    /// - Parameters:
    ///     - value: The value to evaluate.
    ///     - shouldEvaluate: A binding that tells us when it's ok to evaluate the value.
    ///     - alignment: Alignment guide for the `VStack` that holds the content and errors.
    ///     - validator: A `Validator`, used to validate the value.
    public func errorModifer<V>(
        value: Binding<V>,
        shouldEvaluate: Binding<Bool> = .constant(true),
        alignment: HorizontalAlignment = .leading,
        validator: Validator<V>
    ) -> some View
    {
        self.modifier(
            ErrorViewModifier(
                value: value,
                shouldEvaluate: shouldEvaluate,
                alignment: alignment,
                validator: validator
            ) { errors in
                MultiErrorView(errors)
            }
        )
    }

    /// Add an error modifier / validation to a view, with a default error view builder.
    ///
    ///
    ///  - Note:
    ///     The default error view, which is called for each error generated during validation.
    ///     ``` swift
    ///     ForEach(errors, id: \.self) { error in
    ///         Text(error)
    ///             .font(.callout)
    ///             .foregroundColor(.red)
    ///     }
    ///     ```
    ///
    /// - Parameters:
    ///     - value: The value to validate.
    ///     - shouldEvaluate: A binding that tells us when it's ok to evaluate the value.
    ///     - alignment: Alignment guide for the `VStack` that holds the content and errors.
    ///     - validator: A trailing closure that returns a `Validator`, used to validate the value.
    public func errorModifer<V>(
        value: Binding<V>,
        shouldEvaluate: Binding<Bool> = .constant(true),
        alignment: HorizontalAlignment = .leading,
        validator: @escaping () -> Validator<V>
    ) -> some View
    {
        self.errorModifer(
            value: value,
            shouldEvaluate: shouldEvaluate,
            alignment: alignment,
            validator: validator()
        )
    }
}
