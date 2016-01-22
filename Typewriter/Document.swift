//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

import Prelude

// MARK: - DocumentType

public protocol DocumentType: Monoid {
	static var empty: Self { get }
	static func char(x: Character) -> Self
	static func text(x: String) throws -> Self
	static var hardline: Self { get }
	static var line: Self { get }
	static var linebreak: Self { get }
	static func union(x: Self, _ y: Self) -> Self
	
	func flatten() -> Self
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

// MARK: - DocumentConstructError

public enum DocumentConstructError: ErrorType {
	case ContainsLinebreak
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
	
	public static func text(x: String) throws -> Document {
		switch x {
		case "":
			return .empty
		default:
			if x.characters.contains("\n") {
				throw DocumentConstructError.ContainsLinebreak
			}else {
				return .Text(x)
			}
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
	
	public func flatten() -> Document {
		switch self {
		case let .Cat(x, y):
			return .Cat(x.flatten(), y.flatten())
		case let .FlatAlt(_, x):
			return x
		case .Line:
			return .Fail
		case let .Union(x, _):
			return x.flatten()
		default:
			return self
		}
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
	
	public static func string(str: String) -> Self {
		return str.characters
			.split{ $0 == "\n" }
			.map{ try! Self.text(String($0)) }
			.vsep()
	}
	
	public static func texts(str: String) -> [Self] {
		return str.characters
			.split{ $0 == " " }
			.map{ Self.string(String($0)) }
	}
}

// MARK: DocumentType (Rendering Rule Dependence)

extension DocumentType {
	
	///
	/// `group` selects the document by fitting.
	/// `self.flatten` is selected if the resulting output fits the page,
	/// otherwise `self` is selected.
	///
	public func group() -> Self {
		return .union(self.flatten(), self)
	}
	
	///
	/// `softline` behaves like `space` if the retsulting output fits the page,
	/// otherwise it behaves like `line`.
	///
	public static var softline: Self {
		return Self.line.group()
	}
	
	///
	/// `softbreak` behaves like `empty` if the resulting output fits the page,
	/// otherwise it behaves like `line`.
	///
	public static var softbreak: Self {
		return Self.linebreak.group()
	}
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
	
	///
	/// 'hcat()` concatenates all documents.
	///
	public func hcat() -> Element {
		return fold(<>)
	}
	
	///
	/// `vcat()` concatenates all documents vertically with `</-> .linebreak`.
	///
	public func vcat() -> Element {
		return fold(</->)
	}
	
	///
	/// `cat()` concatenates all documents horizontally with `<>`, if it fits the page,
	/// or vertically with `</-> .linebreak`
	///
	public func cat() -> Element {
		return vcat().group()
	}
	
	///
	/// `fillCat()` concatenates all documents horizontally with `<>` as long as it fits the page,
	/// than inserts a `</-> .linebreak` and continues doing that for all documents.
	///
	public func fillCat() -> Element {
		return fold(<-/->)
	}
	
	///
	/// `hsep()` concatenates all documents with `<+> .space`.
	///
	public func hsep() -> Element {
		return fold(<+>)
	}
	
	///
	/// `vsep()` concatenates all documents vertically with `</+> .line`
	///
	public func vsep() -> Element {
		return fold(</+>)
	}
	
	///
	/// `sep()` concatenates all documents horizontally with `<+> .space`, if it fits the page,
	/// or vertically with `</+> .line`
	///
	public func sep() -> Element {
		return vsep().group()
	}
	
	///
	/// `fillSep()` concatenates all documents horizontally with `<+> .space` as long as if it fits the page,
	/// than inserts a `</+> .line` and continues doing that for all documents.
	///
	public func fillSep() -> Element {
		return fold(<+/+>)
	}
}

// MARK: - Operators

///
/// + : space
/// - : empty
/// / : line break
///
/// ** left side has a priority higher than right side **
///

///
/// concat
///
public func <> <D: DocumentType>(lhs: D, rhs: D) -> D {
	return lhs.beside(rhs)
}

///
/// `<+>` space(: +) encloses in `lhs` and `rhs`.
///
public func <+> <D: DocumentType>(lhs: D, rhs: D) -> D {
	return lhs <> D.space <> rhs
}

///
/// `</+>` `.line` encloses in `lhs` and `rhs`.
/// `.line` behaves like a line break (/).
/// `.line` behaves like a space (+), if the line break is undone by `group`.
///
public func </+> <D: DocumentType>(lhs: D, rhs: D) -> D {
	return lhs <> D.line <> rhs
}

///
/// `</->` `.linebreak` encloses in `lhs` and `rhs`.
/// `.linebreak` behaves like a line break (/).
/// `.linebreak` behaves like a empty (-), if the line break is undone by `group`.
///
public func </-> <D: DocumentType>(lhs: D, rhs: D) -> D {
	return lhs <> D.linebreak <> rhs
}

///
/// `<+/+>` `.softline` encloses in `lhs` and `rhs`.
/// `.softline` behaves like a space (+), if the resulting output fits the page,
/// otherwise it behaves like a `line` (/+)
///
public func <+/+> <D: DocumentType>(lhs: D, rhs: D) -> D {
	return lhs <> D.softline <> rhs
}

///
/// `<-/->` `.softbreak` encloses in `lhs` and `rhs`.
/// `.softbreak` behaves like a empty (-), if the resulting output fits the page,
/// otherwise it behaves like a `linebreak` (/-)
///
public func <-/-> <D: DocumentType>(lhs: D, rhs: D) -> D {
	return lhs <> D.softbreak <> rhs
}