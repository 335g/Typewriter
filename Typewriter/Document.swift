//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

import Prelude

// MARK: - DocumentType

public protocol DocumentType: Monoid {
	static var empty: Self { get }
	static func char(x: Character) -> Self
	static var hardline: Self { get }
	static var line: Self { get }
	static var linebreak: Self { get }
	static func union(x: Self, _ y: Self) -> Self
	
	func beside(other: Self) -> Self
}

// MARK: DocumentType : Monoid

extension DocumentType {
	public static var mempty: Self {
		return .empty
	}
	
	public func mappend(other: Self) -> Self {
		return beside(other)
	}
}

// MARK: - Document

public indirect enum Document: DocumentType {
	case Fail
	case Empty
	case Char(Character)
	case Text(String)
	case Line
	case Cat(Document, Document)
	case FlatAlt(Document, Document)
	case Union(Document, Document)
}

// MARK: Document : DocumentType

extension Document {
	public static var empty: Document {
		return .Empty
	}
	
	public static func char(x: Character) -> Document {
		switch x {
		case "\n":
			return .Line
			
		default:
			return .Char(x)
		}
	}
	
	public static var hardline: Document {
		return .Line
	}
	
	public static var line: Document {
		return .FlatAlt(.hardline, .space)
	}
	
	public static var linebreak: Document {
		return .FlatAlt(.hardline, .empty)
	}
	
	public static func union(x: Document, _ y: Document) -> Document {
		return .Union(x, y)
	}
	
	public func beside(doc: Document) -> Document {
		return .Cat(self, doc)
	}
}

// MARK: DocumentType (Constructor)

extension DocumentType {
	public static var space: Self		{ return .char(" ") }
	public static var comma: Self		{ return .char(",") }
	public static var lparen: Self		{ return .char("(") }
	public static var rparen: Self		{ return .char(")") }
	public static var lbracket: Self	{ return .char("[") }
	public static var rbracket: Self	{ return .char("]") }
	public static var langle: Self		{ return .char("<") }
	public static var rangle: Self		{ return .char(">") }
	public static var lbrace: Self		{ return .char("{") }
	public static var rbrace: Self		{ return .char("}") }
	public static var semi: Self		{ return .char(";") }
	public static var squote: Self		{ return .char("'") }
	public static var dquote: Self		{ return .char("\"") }
	public static var colon: Self		{ return .char(":") }
	public static var dot: Self			{ return .char(".") }
	public static var backslash: Self	{ return .char("\\") }
	public static var equals: Self		{ return .char("=") }
}

// MARK: - extension CollectionType where Index: RandomAccessIndexType

extension CollectionType where Index: RandomAccessIndexType {
	typealias Element = Generator.Element
	
	func foldr<T>(initial: T, @noescape _ f: Element -> T -> T) -> T {
		return self.reverse().reduce(initial){ f($0.1)($0.0) }
	}
	
	func foldr1(f: Element -> Element -> Element) throws -> Element {
		let element: Element -> Element? -> Element
		element = { x in
			{ m in
				switch m {
				case .None:
					return x
				case let .Some(a):
					return f(x)(a)
				}
			}
		}
		
		if let result = foldr(nil, element) {
			return result
		}else {
			throw CollectionTypeFoldError.OnlyOne
		}
	}
}

enum CollectionTypeFoldError: ErrorType {
	case OnlyOne
}

// MARK: - extension Array where Element: DocumentType

public extension Array where Element: DocumentType {
	func fold(f: (Element, Element) -> Element) -> Element {
		guard let first = self.first else {
			return .empty
		}
		
		if let result = try? foldr1(curry(f)) {
			return result
		}else {
			return first
		}
	}
	
	
}