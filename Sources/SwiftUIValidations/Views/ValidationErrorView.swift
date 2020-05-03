//
//  ValidationErrorView.swift
//  
//
//  Created by Michael Housh on 5/3/20.
//

import SwiftUI
import ViewInspector

public protocol ValidationErrorView: View {
    var errors: Binding<[String]> { get set }
    init(_ errors: Binding<[String]>)
}

public struct DefaultValidationErrorView: ValidationErrorView, Inspectable {

    public var errors: Binding<[String]>

    internal let inspection = Inspection<Self>()

    public init(_ errors: Binding<[String]>) {
        self.errors = errors
    }

    public var body: some View {
        ForEach(errors.wrappedValue, id: \.self) { error in
            Text(error)
                .font(.callout)
                .foregroundColor(.red)
        }
        .onReceive(inspection.notice) { self.inspection.visit(self, $0) }

    }
}
