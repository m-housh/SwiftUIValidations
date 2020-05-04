//
//  ValidatableTextField.swift
//
//  Created by Michael Housh on 4/29/20.
//  Copyright © 2020 Michael Housh. All rights reserved.
//

import SwiftUI
import Combine

/// A text field that is able to validate it's value once it's been changed.  By default the text field will not evaluate until the field
/// has been entered, then exited for the first time.
public struct ValidatingTextField<ErrorView>: View where ErrorView: View {

    /// The placeholder text for the field.
    let placeholder: String

    /// The value of the text field.
    @Binding var text: String

    /// A flag for when the field is being edited or not.
    @State private var isInFocus: Bool = false

    /// A flag for if we should evalute / validate the value or not.
    /// Unless specified by the user, then this will remain false until the textfield has been entered and exited.
    /// Upon re-enter then we will disable validation, until editing is complete.
    @State private var shouldEvaluate: Bool = false

    /// Allows the user to hook into editing changed events for the textfield.
    let onEditingChanged: (Bool) -> Void

    /// Allows the user too hook into commit events for the textfield.
    let onCommit: () -> Void

    /// The validator for the field.
    let validator: Validator<String>

    /// Buiilds the view for errors thrown from validations.
    let errorViewBuilder: ([String]) -> ErrorView

    /// Create a new validatable text field.
    ///
    /// - Parameters:
    ///     - placeholder: The placeholder text that shows inside the field when the value is empty.
    ///     - text: A binding to the text field's value.
    ///     - alwaysEvaluate: A flag to override the default behaviour of waiting for field to evaluate until after it's been entered once.
    ///     - onEditingChanged:  Passed to the actual `TextField`
    ///     - onCommit:  Passed to the actual `TextField`
    ///     - validator: A `Validator` to use to validate the text.
    public init(
        _ placeholder: String = "",
        text: Binding<String>,
        alwaysEvaluate: Bool = false,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { },
        validator: Validator<String>,
        @ViewBuilder errorView: @escaping ([String]) -> ErrorView
    ) {
        self.placeholder = placeholder
        self._text = text
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
        self.validator = validator
        self.errorViewBuilder = errorView
        if alwaysEvaluate == true {
            self._shouldEvaluate = .init(initialValue: true)
        }
    }

    public var body: some View {
        TextField(
            placeholder,
            text: $text,
            onEditingChanged: self.editingChanged,
            onCommit: { self.onCommit() }
        )
            .errorModifer(value: $text, shouldEvaluate: $shouldEvaluate, validator: validator, errorViewBuilder)

    }

    // MARK: - Helpers
    private func editingChanged(_ isInFocus: Bool) {
        if isInFocus {
            self.isInFocus = true
        } else {
            self.isInFocus = false
            self.shouldEvaluate = true
        }
        self.onEditingChanged(isInFocus)
    }
}

// MARK: - Default Error View
extension ValidatingTextField where ErrorView == ForEach<[String], String, Text> {

    /// Create a new validatable text field.
    ///
    /// - Parameters:
    ///     - placeholder: The placeholder text that shows inside the field when the value is empty.
    ///     - text: A binding to the text field's value.
    ///     - alwaysEvaluate: A flag to override the default behaviour of waiting for field to evaluate until after it's been entered once.
    ///     - onEditingChanged:  Passed to the actual `TextField`
    ///     - onCommit:  Passed to the actual `TextField`
    ///     - validator: A `Validator` to use to validate the text.
    public init(
        _ placeholder: String = "",
        text: Binding<String>,
        alwaysEvaluate: Bool = false,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { },
        validator: Validator<String>
    ) {
        self.init(
            placeholder,
            text: text,
            alwaysEvaluate: alwaysEvaluate,
            onEditingChanged: onEditingChanged,
            onCommit: onCommit,
            validator: validator
        ) { errors in
            ForEach(errors, id: \.self) {
                Text($0)
                    .font(.callout)
                    .foregroundColor(.red)
            }
        }
    }
}
