//
//  MultiErrorView.swift
//  
//
//  Created by Michael Housh on 5/4/20.
//

import SwiftUI

/// The default error view that will display all the validatiion errors.
public struct MultiErrorView: View {

    /// The validation errors.
    private let errors: [String]

    /// Create a new view.
    ///
    /// - Parameters:
    ///     - errors: The validation errorrs to display.
    public init(_ errors: [String]) {
        self.errors = errors
    }

    public var body: some View {
        ForEach(errors, id: \.self) { error in
            Text(error.capitalizedFirstLetter())
                .modifier(ErrorTextModifier())
        }
    }
}

internal extension String {

    /// Capitalize the first letter of a string.
    func capitalizedFirstLetter() -> String {
        return self.prefix(1).capitalized + self.dropFirst()
    }
}
