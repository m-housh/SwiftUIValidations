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
    ///     let validator = Validator<String>.count(5...10)
    ///
    /// - errorText: where T == String: `between 5 and 10 characters`
    /// - errorText: where T: Collection: `between 5 and 10 items`
    public static func count(_ range: ClosedRange<Int>) -> Validator<T> {
        CountValidator(RangeType<Int>.closedRange(min: range.lowerBound, max: range.upperBound)).validator()
    }

    /// Validates that the data's count is less than the supplied upper bound using `PartialRangeThrough`.
    ///
    ///     let validator = Validator<String>.count(...10)
    ///
    /// - errorText: where T == String: `at most 10 characters`
    /// - errorText: where T: Collection: `at most 10 items`
    public static func count(_ range: PartialRangeThrough<Int>) -> Validator<T> {
        CountValidator(RangeType<Int>.partialRangeMax(max: range.upperBound)).validator()
    }

    /// Validates that the data's count is less than the supplied lower bound using `PartialRangeFrom`.
    ///
    ///     let validator = Validator<String>.count(5...)
    ///
    /// - errorText: where T == String: `at least 5 characters`
    /// - errorText: where T: Collection: `at least 5 items`
    public static func count(_ range: PartialRangeFrom<Int>) -> Validator<T> {
        CountValidator(RangeType<Int>.partialRangeMin(min: range.lowerBound)).validator()
    }

    /// Validates that the data's count is within the supplied `Range`.
    ///
    ///     let validator = Validator<String>.count(5..<10)
    ///
    /// - errorText: where T == String: `between 5 and 9 characters`
    /// - errorText: where T: Collection: `between 5 and 9 items`
    public static func count(_ range: Range<Int>) -> Validator<T> {
        CountValidator(RangeType<Int>.range(min: range.lowerBound, max: range.upperBound.advanced(by: -1))).validator()
    }
}

// MARK: Private
/// Validates whether the item's count is within a supplied int range.
struct CountValidator<T>: ValidatorType where T: Collection {

    let countType: RangeType<Int>

    /// See `ValidatorType`.
    var errorText: String {
        "\(countType.readable(self.elementDescription))"
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
                throw BasicValidationError(errorText)
            }
        }

        if let max = self.countType.max {
            guard data.count <= max else {
                throw BasicValidationError(errorText)
            }
        }
    }
}
