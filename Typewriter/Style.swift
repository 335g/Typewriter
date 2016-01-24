//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

public protocol DocumentStyleType {
	func wrap(str: String) -> String
}

public extension DocumentStyleType {
	public func wrap(str: String) -> String {
		return ""
	}
}

public struct DocumentStyle: DocumentStyleType {
	
	public enum Intensity: UInt8, StylePropertyType {
		case Bold = 1
		case Faint = 2
	}
	
	public enum Underline: UInt8, StylePropertyType {
		case Single = 4
		case Double = 21
	}
	
	public enum Blink: UInt8, StylePropertyType {
		case Slow = 5
		case Rapid = 6
	}
	
	
}

public protocol StylePropertyType: RawRepresentable {
	typealias RawValue = UInt8
	var code: [RawValue] { get }
}

public extension StylePropertyType {
	public var code: [RawValue] {
		return [self.rawValue]
	}
}