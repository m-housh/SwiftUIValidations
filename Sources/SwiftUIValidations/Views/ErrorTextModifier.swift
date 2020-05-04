//
//  ErrorTextModifier.swift
//  
//
//  Created by Michael Housh on 5/3/20.
//

import SwiftUI

public struct ErrorTextModifier: ViewModifier {

    public func body(content: Content) -> some View {
        content
            .font(.callout)
            .foregroundColor(.red)
    }
}
