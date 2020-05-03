//
//  RangeValidator.swift
//  
//
//  Created by Michael Housh on 5/2/20.
//

import Foundation

extension Validator where T: Comparable {
    /// Validates that the data's count is within the supplied `ClosedRange`.
    ///
    ///     try validations.add(\.age, .count(5...10))
    ///
    public static func range(_ range: ClosedRange<T>) -> Validator<T> {
        RangeValidator(.closedRange(min: range.lowerBound, max: range.upperBound)).validator()
    }

    /// Validates that the data's count is less than the supplied upper bound using `PartialRangeThrough`.
    ///
    ///     try validations.add(\.age, .count(...10))
    ///
    public static func range(_ range: PartialRangeThrough<T>) -> Validator<T> {
        RangeValidator(.partialRangeMax(max: range.upperBound)).validator()
    }

    /// Validates that the data's count is less than the supplied lower bound using `PartialRangeFrom`.
    ///
    ///     try validations.add(\.age, .count(5...))
    ///
    public static func range(_ range: PartialRangeFrom<T>) -> Validator<T> {
        RangeValidator(.partialRangeMin(min: range.lowerBound)).validator()
    }
}


extension Validator where T: Comparable & Strideable {


    /// Validates that the data's count is within the supplied `Range`.
    ///
    ///     try validations.add(\.age, .count(5..<10))
    ///
    public static func range(_ range: Range<T>) -> Validator<T> {
        RangeValidator(.range(min: range.lowerBound, max: range.upperBound.advanced(by: -1))).validator()
    }
}

// MARK: Private
/// Validates whether the item's count is within a supplied int range.
struct RangeValidator<T>: ValidatorType where T: Comparable {

    let countType: RangeType<T>

    /// See `ValidatorType`.
    var validatorReadable: String {
        "Required Range: \(countType.readable())"
    }

    init(_ type: RangeType<T>) {
        self.countType = type
    }

    /// See `ValidatorType`.
    func validate(_ data: T) throws {
        if let min = self.countType.min {
            guard data >= min else {
                throw BasicValidationError(validatorReadable)
            }
        }

        if let max = self.countType.max {
            guard data <= max else {
                throw BasicValidationError(validatorReadable)
            }
        }
    }
}
