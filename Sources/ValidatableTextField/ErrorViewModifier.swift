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

    @Binding var value: Value
    @Binding var shouldEvaluate: Bool
    @State private var errors: [String] = []
    private let validator: Validator<Value>

    // Used for inspection testing.
    internal var didAppear: ((Self.Body) -> Void)?

    init(
        value: Binding<Value>,
        shouldEvaluate: Binding<Bool>,
        validator: Validator<Value>
    ) {
        self._value = value
        self._shouldEvaluate = shouldEvaluate
        self.validator = validator
    }

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

    public func errorModifer<V>(
        errors: [String],
        value: Binding<V>,
        shouldEvaluate: Binding<Bool> = .constant(true),
        validate: @escaping (V) -> Bool
    ) -> some View {
        self.modifier(
            ErrorViewModifier(
                errors: errors,
                value: value,
                shouldEvaluate: shouldEvaluate,
                validate: validate
            )
        )
    }

    public func errorModifier<V>(
        value: Binding<V>,
        shouldEvaluate: Binding<Bool> = .constant(true),
        keyPath: KeyPath<Validators<V>, Validator<V>>
    ) -> some View {
        self.modifier(
            ErrorViewModifier(
                value: value,
                shouldEvaluate: shouldEvaluate,
                validator: Validators<V>()[keyPath: keyPath]
            )
        )
    }

    public func errorModifier<V>(
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
