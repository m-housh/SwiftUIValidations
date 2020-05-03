//
//  Inspection.swift
//  
//
//  Created by Michael Housh on 5/3/20.
//

import SwiftUI
import Combine

internal final class Inspection<V> where V: View {

    let notice = PassthroughSubject<UInt, Never>()
    var callbacks = [UInt: (V) -> Void]()

    func visit(_ view: V, _ line: UInt) {
        if let callback = callbacks.removeValue(forKey: line) {
            callback(view)
        }
    }
}
