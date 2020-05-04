//
//  UrlValidator.swift
//  
//
//  Created by Michael Housh on 5/3/20.
//

import Foundation

extension Validator where T == String {
    /// Validates whether a `String` is a valid URL.
    ///
    ///     let validator: Validator<String> = .url
    ///
    ///     alternatively, if you want to allow an optional URL:
    ///
    ///     let validator: Validator<String?> = .url || .nil
    ///
    /// This validator will allow either file URLs, or URLs
    /// containing at least a scheme and a host.
    ///
    /// - errorText: `invalid url`
    /// - inverseErrorText: `valid url`
    public static var url: Validator<T> {
        return URLValidator().validator()
    }
}

// MARK: Private
/// Validates whether a string is a valid email address.
private struct URLValidator: ValidatorType {

    typealias ValidationData = String

    /// See `ValidatorType`.
    let errorText: String = "invalid url"
    let inverseErrorText: String = "valid url"

    /// Creates a new `URLValidator`.
    public init() {}

    /// See `Validator`.
    func validate(_ data: String) throws {
        guard let url = URL(string: data),
            url.isFileURL || (url.host != nil && url.scheme != nil) else {
            throw BasicValidationError(errorText)
        }
    }
}
