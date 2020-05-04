//
//  SingleErrorView.swift
//  
//
//  Created by Michael Housh on 5/4/20.
//

import SwiftUI

/// Can be used to customize the errors displayed during validation.  This will display a single error, either the first or the last depending
/// on initialization.  Default is to display the first errror.
///
/// This would typically be used when you want to customize the error displayed.
/// ``` swift
///
///     @State private var decimal: Decimal? = nil
///
///     let validator: Validator<Decimal?> = .custom("Must be greater than 0", .nil || .range(0...))
///     ...
///     var body: some View {
///         Text("")
///             .errorModifier(value: $decimal, validator: validator) { errors in
///                 SingleErrorView(errors, displaying: .last)
///              }
///     }
///```
public struct SingleErrorView: View {

    /// The errors to display either the first or last value of.
    private let errors: [String]

    /// The error to display (either `first` or `last`)
    private let displayError: DisplayError

    /// Create a new single error view.
    ///
    /// - Parameters:
    ///     - errors: The validation errors to display.
    ///     - displayError: Controls which error(s) to display.
    public init(_ errors: [String], displaying displayError: DisplayError = .first) {
        self.errors = errors
        self.displayError = displayError
    }

    public var body: some View {
        Group {
            if displayError == .first && errors.first != nil {
                Text(errors.first!.capitalizedFirstLetter())
                    .modifier(ErrorTextModifier())
            } else if errors.last != nil {
                Text(errors.last!.capitalizedFirstLetter())
                    .modifier(ErrorTextModifier())
            }
        }
    }
}

extension SingleErrorView {

    /// Which error to display in the `SingleErrorView`
    public enum DisplayError {
        case first, last
    }
}
