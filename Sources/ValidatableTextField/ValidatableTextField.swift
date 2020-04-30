//
//  ValidatableTextField.swift
//
//  Created by Michael Housh on 4/29/20.
//  Copyright © 2020 Michael Housh. All rights reserved.
//

import SwiftUI
import Combine

public struct ValidatableTextField: View {

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
    let onEditingChanged: (Bool) -> ()

    /// Allows the user too hook into commit events for the textfield.
    let onCommit: () -> ()

    /// The validator for the field.
    let validator: Validator<String>

    public init(
        _ placeholder: String = "",
        text: Binding<String>,
        validator: Validator<String> = .empty,
        alwaysEvaluate: Bool = false,
        onEditingChanged: @escaping (Bool) -> () = { _ in },
        onCommit: @escaping () -> () = { }
    ) {
        self.placeholder = placeholder
        self._text = text
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
        self.validator = validator
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
            .errorModifier(value: $text, shouldEvaluate: $shouldEvaluate, validator: validator)

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

