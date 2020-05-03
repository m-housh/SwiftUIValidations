//
//  RangeType.swift
//  
//
//  Created by Michael Housh on 5/2/20.
//

import Foundation

enum RangeType<T> {
    case closedRange(min: T, max: T)
    case partialRangeMax(max: T)
    case partialRangeMin(min: T)
    case range(min: T, max: T)
}

extension RangeType {
    var min: T? {
        switch self {
        case let .closedRange(min, _): return min
        case let .partialRangeMin(min): return min
        case let .range(min, _): return min
        case .partialRangeMax: return nil
        }
    }

    var max: T? {
        switch self {
        case let .closedRange(_, max): return max
        case let .partialRangeMax(max): return max
        case let .range(_, max): return max
        case .partialRangeMin: return nil
        }
    }

    func readable(
        _ elementDescription: @escaping (T) -> String = { "\($0)" }
    ) -> String {
        switch self {
        case let .closedRange(min, max):
            return "between \(min) and \(elementDescription(max))"
        case let .partialRangeMax(max):
            return "at most \(elementDescription(max))"
        case let .partialRangeMin(min):
            return "at least \(elementDescription(min))"
        case let .range(min, max):
            return "between \(min) and \(elementDescription(max))"
        }
    }
}
