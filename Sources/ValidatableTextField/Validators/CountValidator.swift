//
//  CountValidator.swift
//  
//
//  Created by Michael Housh on 5/2/20.
//

import Foundation

extension Validator where T: Collection {
    /// Validates that the data's count is within the supplied `ClosedRange`.
    ///
    ///     try validations.add(\.name, .count(5...10))
    ///
    public static func count(_ range: ClosedRange<Int>) -> Validator<T> {
        CountValidator(RangeType<Int>.closedRange(min: range.lowerBound, max: range.upperBound)).validator()
    }

    /// Validates that the data's count is less than the supplied upper bound using `PartialRangeThrough`.
    ///
    ///     try validations.add(\.name, .count(...10))
    ///
    public static func count(_ range: PartialRangeThrough<Int>) -> Validator<T> {
        CountValidator(RangeType<Int>.partialRangeMax(max: range.upperBound)).validator()
    }

    /// Validates that the data's count is less than the supplied lower bound using `PartialRangeFrom`.
    ///
    ///     try validations.add(\.name, .count(5...))
    ///
    public static func count(_ range: PartialRangeFrom<Int>) -> Validator<T> {
        CountValidator(RangeType<Int>.partialRangeMin(min: range.lowerBound)).validator()
    }

    /// Validates that the data's count is within the supplied `Range`.
    ///
    ///     try validations.add(\.name, .count(5..<10))
    ///
    public static func count(_ range: Range<Int>) -> Validator<T> {
        CountValidator(RangeType<Int>.range(min: range.lowerBound, max: range.upperBound.advanced(by: -1))).validator()
    }
}

// MARK: Private
/// Validates whether the item's count is within a supplied int range.
struct CountValidator<T>: ValidatorType where T: Collection {

    let countType: RangeType<Int>

    /// See `ValidatorType`.
    var validatorReadable: String {
        "Required Count: \(countType.readable(self.elementDescription))"
    }

    func elementDescription(_ count: Int) -> String {
        if T.Element.self is Character.Type {
            return count == 1 ? "1 character" : "\(count) characters"
        } else {
            return count == 1 ? "1 item" : "\(count) items"
        }
    }

    init(_ type: RangeType<Int>) {
        self.countType = type
    }

    /// See `ValidatorType`.
    func validate(_ data: T) throws {
        if let min = self.countType.min {
            guard data.count >= min else {
                throw BasicValidationError(validatorReadable)
            }
        }

        if let max = self.countType.max {
            guard data.count <= max else {
                throw BasicValidationError(validatorReadable)
            }
        }
    }
}
