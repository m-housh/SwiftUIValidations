//
//  ErrorTextModifier.swift
//  
//
//  Created by Michael Housh on 5/3/20.
//

import SwiftUI

/// Adds default styling to a view that's displaying errors.
public struct ErrorTextModifier: ViewModifier {

    /// Create a new error modifier.
    public init() { }

    public func body(content: Content) -> some View {
        content
            .font(.callout)
            .foregroundColor(.red)
    }
}
