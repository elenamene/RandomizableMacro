import Foundation
import SwiftUI
import Combine

public protocol Randomizable {
    static func makeRandom() -> Self
}

public extension Randomizable where Self: CaseIterable {
    static func makeRandom() -> Self {
        allCases.randomElement()!
    }
}

extension Optional: Randomizable where Wrapped: Randomizable {
    public static func makeRandom() -> Wrapped? {
        Bool.random() ? Wrapped.makeRandom() : nil
    }
}

extension Date: Randomizable {
    public static func makeRandom() -> Date {
        var calendar = Calendar.current
        if let timeZone = TimeZone(secondsFromGMT: 0) {
            calendar.timeZone = timeZone
        }
        let components = DateComponents(
            calendar: calendar,
            year: Int.makeRandom(min: 1970, max: 2030),
            month: Int.makeRandom(min: 1, max: 12),
            day: Int.makeRandom(min: 1, max: 30),
            hour: Int.makeRandom(min: 0, max: 23),
            minute: Int.makeRandom(min: 0, max: 59),
            second: Int.makeRandom(min: 0, max: 59)
        )
        return calendar.date(from: components)!
    }
}

extension DateComponents: Randomizable {
    public static func makeRandom() -> DateComponents {
        var calendar = Calendar.current
        if let timeZone = TimeZone(secondsFromGMT: 0) {
            calendar.timeZone = timeZone
        }
        return DateComponents(
            calendar: calendar,
            year: Int.makeRandom(min: 1970, max: 2030),
            month: Int.makeRandom(min: 1, max: 12),
            day: Int.makeRandom(min: 1, max: 30),
            hour: Int.makeRandom(min: 0, max: 23),
            minute: Int.makeRandom(min: 0, max: 59),
            second: Int.makeRandom(min: 0, max: 59)
        )
    }
}

extension Double: Randomizable {}
extension CGFloat: Randomizable {}

public extension BinaryFloatingPoint where Self: Randomizable, RawSignificand: FixedWidthInteger {
    static func makeRandom() -> Self {
        let first = Self(Int.makeRandom())
        let second = Self(Int.makeRandom())
        return makeRandom(min: min(first, second), max: max(first, second))
    }

    static func makeRandom(min: Self, max: Self) -> Self {
        random(in: min ... max)
    }
}

extension Int: Randomizable {}
extension UInt: Randomizable {}

public extension FixedWidthInteger where Self: Randomizable {
    static func makeRandom() -> Self {
        makeRandom(min: 0, max: 100)
    }

    static func makeRandom(min: Self, max: Self) -> Self {
        random(in: min ... max)
    }
}

extension Decimal: Randomizable {
    public static func makeRandom() -> Decimal {
        Decimal(Double.makeRandom())
    }
}

extension String: Randomizable {
    public static func makeRandom() -> String {
        String.makeRandom(length: Int.makeRandom(min: 5, max: 10))
    }

    public static func makeRandom(length: Int) -> String {
        makeRandom(
            length: length,
            allowedChars: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        )
    }

    static func makeRandom(length: Int, allowedChars: String) -> String {
        let allowedCharsStr = allowedChars as NSString
        return (0 ..< length).map { _ in
            let index = Int.makeRandom(min: 0, max: allowedCharsStr.length - 1)
            var character = allowedCharsStr.character(at: index)
            return NSString(characters: &character, length: 1) as String
        }
        .joined()
    }

    static func makeRandomURL() -> String {
        "http://\(makeRandom(length: 10)).com/\(makeRandom(length: 5))"
    }
}

extension URL: Randomizable {
    public static func makeRandom() -> URL {
        URL(string: String.makeRandomURL())!
    }
}

extension Bool: Randomizable {
    public static func makeRandom() -> Bool { Bool.random() }
}

extension Array: Randomizable where Element: Randomizable {
    public static func makeRandom() -> Array {
        [Element.makeRandom(), Element.makeRandom()]
    }
}

extension AnyPublisher: Randomizable where Output: Randomizable {
    public static func makeRandom() -> AnyPublisher<Output, Failure> {
        Just(Output.makeRandom()).setFailureType(to: Failure.self).eraseToAnyPublisher()
    }
}

extension UUID: Randomizable {
    public static func makeRandom() -> UUID {
        UUID()
    }
}

extension Color: Randomizable {
    public static func makeRandom() -> Self {
        Self(
            red: .makeRandom(min: 0, max: 1),
            green: .makeRandom(min: 0, max: 1),
            blue: .makeRandom(min: 0, max: 1)
        )
    }
}

extension Float: Randomizable {
    public static func makeRandom() -> Float {
        Float(CGFloat.makeRandom())
    }
}

extension ClosedRange: Randomizable where Bound == Date {
    public static func makeRandom() -> ClosedRange<Bound> {
        let lowerBound = Date.makeRandom()
        let upperBound = lowerBound.addingTimeInterval(TimeInterval(Int.makeRandom()))
        return lowerBound ... upperBound
    }
}

extension Dictionary: Randomizable {
    public static func makeRandom() -> [Key: Value] {
        [:]
    }

    public static func makeRandom() -> [Key: Any] where Key: Randomizable {
        [Key].makeRandom().reduce(into: [:]) {
            $0[$1] = String.makeRandom()
        }
    }

    public static func makeRandom() -> [Key: Value] where Key: Randomizable, Value: Randomizable {
        [Key].makeRandom().reduce(into: [:]) {
            $0[$1] = Value.makeRandom()
        }
    }
}

extension Data: Randomizable {
    public static func makeRandom() -> Data { Data() }
}
