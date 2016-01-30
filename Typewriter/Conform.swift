//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - Typewritable

public protocol Typewritable {
	func pretty() -> Document
}

// MARK: - DescriptionTypewritable

public protocol DescriptionTypewritable: CustomStringConvertible, Typewritable {}
extension DescriptionTypewritable {
	public func pretty() -> Document {
		return try! .text(self.description)
	}
}

// MARK: - Adopted: Typewritable

extension String: Typewritable {
	public func pretty() -> Document {
		return .string(self)
	}
}

extension String.CharacterView: Typewritable {
	public func pretty() -> Document {
		return .string(String(self))
	}
}

extension NSString: Typewritable {
	public func pretty() -> Document {
		return .string(String(self))
	}
}

extension Int: DescriptionTypewritable {}
extension Int16: DescriptionTypewritable {}
extension Int32: DescriptionTypewritable {}
extension Int64: DescriptionTypewritable {}
extension Int8: DescriptionTypewritable {}
extension UInt: DescriptionTypewritable {}
extension UInt16: DescriptionTypewritable {}
extension UInt32: DescriptionTypewritable {}
extension UInt64: DescriptionTypewritable {}
extension UInt8: DescriptionTypewritable {}
extension Float: DescriptionTypewritable {}
extension Double: DescriptionTypewritable {}
extension Array: DescriptionTypewritable {}
extension ArraySlice: DescriptionTypewritable {}
extension Bool: DescriptionTypewritable {}
extension ClosedInterval: DescriptionTypewritable {}
extension HalfOpenInterval: DescriptionTypewritable {}
extension UnicodeScalar: DescriptionTypewritable {}
extension String.UnicodeScalarView: DescriptionTypewritable {}
extension String.UTF16View: DescriptionTypewritable {}
extension String.UTF8View: DescriptionTypewritable {}
extension Set: DescriptionTypewritable {}
extension Range: DescriptionTypewritable {}
