//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - DocumentConvertible

public protocol DocumentConvertible {
	var document: Document { get }
}

extension Document: DocumentConvertible {
	public var document: Document {
		return self
	}
}

// MARK: - SimpleDocumentConvertible

public protocol SimpleDocumentConvertible: CustomStringConvertible, DocumentConvertible {}
extension SimpleDocumentConvertible {
	public var document: Document {
		return try! .text(self.description)
	}
}

// MARK: - Conform DocumentConvertible

extension String: DocumentConvertible {
	public var document: Document {
		return .string(self)
	}
}

extension String.CharacterView: DocumentConvertible {
	public var document: Document {
		return .string(String(self))
	}
}

extension NSString: DocumentConvertible {
	public var document: Document {
		return .string(String(self))
	}
}

extension Optional: DocumentConvertible {
	public var document: Document {
		switch self {
		case .None:
			return "nil"
		case let .Some(a):
			if let obj = a as? SimpleDocumentConvertible {
				return obj.document
			}else if let obj = a as? DocumentConvertible {
				return obj.document
			}else {
				return "\(a)".document
			}
		}
	}
}

extension Int: SimpleDocumentConvertible {}
extension Int16: SimpleDocumentConvertible {}
extension Int32: SimpleDocumentConvertible {}
extension Int64: SimpleDocumentConvertible {}
extension Int8: SimpleDocumentConvertible {}
extension UInt: SimpleDocumentConvertible {}
extension UInt16: SimpleDocumentConvertible {}
extension UInt32: SimpleDocumentConvertible {}
extension UInt64: SimpleDocumentConvertible {}
extension UInt8: SimpleDocumentConvertible {}
extension Float: SimpleDocumentConvertible {}
extension Double: SimpleDocumentConvertible {}
extension Array: SimpleDocumentConvertible {}
extension ArraySlice: SimpleDocumentConvertible {}
extension Bool: SimpleDocumentConvertible {}
extension ClosedInterval: SimpleDocumentConvertible {}
extension HalfOpenInterval: SimpleDocumentConvertible {}
extension UnicodeScalar: SimpleDocumentConvertible {}
extension String.UnicodeScalarView: SimpleDocumentConvertible {}
extension String.UTF16View: SimpleDocumentConvertible {}
extension String.UTF8View: SimpleDocumentConvertible {}
extension Set: SimpleDocumentConvertible {}
extension Range: SimpleDocumentConvertible {}
