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
	static func column(f: Int -> Self) -> Self
	static func nesting(f: Int -> Self) -> Self
	func nest(i: Int) -> Self
	
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

public indirect enum Document: DocumentType, StringLiteralConvertible, Equatable {
	case Fail
	case Empty
	case Char(Character)
	case Text(String)
	case Line
	case Cat(Document, Document)
	case FlatAlt(Document, Document)
	case Union(Document, Document)
	case Nest(Int, Document)
	case Nesting(Int -> Document)
	case Column(Int -> Document)
}

// MARK: Document : StringLiteralConvertible

extension Document {
	public init(stringLiteral value: StringLiteralType) {
		self = .string(value)
	}
	
	public init(unicodeScalarLiteral value: String) {
		self = .string(value)
	}
	
	public init(extendedGraphemeClusterLiteral value: String) {
		self = .string(value)
	}
}

// MARK: Document : Equatable

public func == (lhs: Document, rhs: Document) -> Bool {
	switch (lhs, rhs) {
	case (.Fail, .Fail):
		return true
	case (.Empty, .Empty):
		return true
	case let (.Char(l), .Char(r)):
		return l == r
	case let (.Text(l), .Text(r)):
		return l == r
	case (.Line, .Line):
		return true
	case let (.Nest(li, ldoc), .Nest(ri, rdoc)):
		return li == ri && ldoc == rdoc
	case let (.Cat(lx, ly), .Cat(rx, ry)):
		return lx == rx && ly == ry
	case let (.FlatAlt(lx, ly), .FlatAlt(rx, ry)):
		return lx == rx && ly == ry
	case let (.Union(lx, ly), .Union(rx, ry)):
		return lx == rx && ly == ry
	case let (.Column(lf), .Column(rf)):
		return lf(4) == rf(4)
	case let (.Nesting(lf), .Nesting(rf)):
		return lf(4) == rf(4)
	default:
		return false
	}
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
	
	public static func column(f: Int -> Document) -> Document {
		return .Column(f)
	}
	
	public static func nesting(f: Int -> Document) -> Document {
		return .Nesting(f)
	}
	
	public func nest(i: Int) -> Document {
		return .Nest(i, self)
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

// MARK: DocumentType (Combinator)

extension DocumentType {
	
	///
	/// `enclose` enclose document in `open` and `close`
	///
	public func enclose(open open: Self, close: Self) -> Self {
		return open <> self <> close
	}
	
	public func squotes() -> Self { return self.enclose(open: .squote, close: .squote) }
	public func dquotes() -> Self { return self.enclose(open: .dquote, close: .dquote) }
	public func parens() -> Self { return self.enclose(open: .lparen, close: .rparen) }
	public func braces() -> Self { return self.enclose(open: .lbrace, close: .rbrace) }
	public func angles() -> Self { return self.enclose(open: .langle, close: .rangle) }
	public func brackets() -> Self { return self.enclose(open: .lbracket, close: .rbracket) }
	
	///
	/// `encloseNest` enclose document in `open` and `close` with nest, if not fits.
	///
	/// ex) 
	///   "abc".encloseNest(2, open: .lbracket, close: .rbracket)
	///
	/// ** if fits **
	///   [abc]
	///
	/// ** if not fits **
	///   [\n
	///     abc\n
	///   ]
	///
	public func encloseNest(i: Int, open: Self, close: Self) -> Self {
		return ((open <-/-> self).hang(i) <-/-> close).align()
	}
	
	public func squotesNest(i: Int) -> Self { return self.encloseNest(i, open: .squote, close: .squote) }
	public func dquotesNest(i: Int) -> Self { return self.encloseNest(i, open: .dquote, close: .dquote) }
	public func parensNest(i: Int) -> Self { return self.encloseNest(i, open: .lparen, close: .rparen) }
	public func bracesNest(i: Int) -> Self { return self.encloseNest(i, open: .lbrace, close: .rbrace) }
	public func anglesNest(i: Int) -> Self { return self.encloseNest(i, open: .langle, close: .rangle) }
	public func bracketsNest(i: Int) -> Self { return self.encloseNest(i, open: .lbracket, close: .rbracket) }
	
	///
	/// `align` renders document with the nesting level set to current column.
	///
	public func align() -> Self {
		return .column({ k in
			.nesting({ i in self.nest(k - i) })
		})
	}
	
	///
	/// `hang` implements hanging indentation.
	/// Document obtained renders document with a nesting level set to the indentation for some text.
	///
	public func hang(i: Int) -> Self {
		return self.nest(i).align()
	}
	
	///
	/// `indent` indents document with `i` spaces.
	///
	public func indent(i: Int) -> Self {
		return (.string(spaces(i)) <> self).hang(i)
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
	
	///
	/// `separator` separates the documents.
	/// And encloses them in `open`(`close`).
	///
	public func encloseSep(separator: Element, open: Element, close: Element) -> Element {
		guard let first = self.first else {
			return open <> close
		}
		
		guard self.count != 1 else {
			return open <> first <> close
		}
		
		var separators = Array(count: self.count - 1, repeatedValue: separator)
		separators.insert(open, atIndex: 0)
		
		return (zipWith(curry(<>))(separators)(self).cat() <> close).align()
	}
	
	///
	/// comma separates the documents.
	/// And encloses them in square brackets.
	///
	public func list() -> Element {
		return encloseSep(.comma, open: .lbracket, close: .rbracket)
	}
	
	///
	/// comma separates the documents.
	/// And encloses them in parenthesis.
	///
	public func tuple() -> Element {
		return encloseSep(.comma, open: .lparen, close: .rparen)
	}
	
	///
	/// comma separates the documents.
	/// And encloses them in `open`(`close`).
	/// Documents is nested, if not fits.
	///
	/// ex) 
	///   ["100","1000","10000"].encloseSepNest(2, sep: .comma, open: .lbracket, close: .rbracket)
	///
	/// ** if fits **
	///   [100,1000,10000]
	///
	/// ** if not fits **
	///   [\n
	///     100,\n
	///     1000,\n
	///     10000
	///   ]\n
	///
	public func encloseSepNest(i: Int, sep: Element, open: Element, close: Element) -> Element {
		guard let first = self.first else {
			return open <> close
		}
		
		guard self.count != 1 else {
			return first.encloseNest(i, open: open, close: close)
		}
		
		return self.fold({ $0 <> sep <-/-> $1 }).encloseNest(i, open: open, close: close)
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
public func <> (lhs: Document, rhs: Document) -> Document {
	return lhs.beside(rhs)
}

///
/// `<+>` space(: +) encloses in `lhs` and `rhs`.
///
public func <+> <D: DocumentType>(lhs: D, rhs: D) -> D {
	return lhs <> .space <> rhs
}
public func <+> (lhs: Document, rhs: Document) -> Document {
	return lhs <> .space <> rhs
}

///
/// `</+>` `.line` encloses in `lhs` and `rhs`.
/// `.line` behaves like a line break (/).
/// `.line` behaves like a space (+), if the line break is undone by `group`.
///
public func </+> <D: DocumentType>(lhs: D, rhs: D) -> D {
	return lhs <> .line <> rhs
}
public func </+> (lhs: Document, rhs: Document) -> Document {
	return lhs <> .line <> rhs
}

///
/// `</->` `.linebreak` encloses in `lhs` and `rhs`.
/// `.linebreak` behaves like a line break (/).
/// `.linebreak` behaves like a empty (-), if the line break is undone by `group`.
///
public func </-> <D: DocumentType>(lhs: D, rhs: D) -> D {
	return lhs <> .linebreak <> rhs
}
public func </-> (lhs: Document, rhs: Document) -> Document {
	return lhs <> .linebreak <> rhs
}

///
/// `<+/+>` `.softline` encloses in `lhs` and `rhs`.
/// `.softline` behaves like a space (+), if the resulting output fits the page,
/// otherwise it behaves like a `line` (/+)
///
public func <+/+> <D: DocumentType>(lhs: D, rhs: D) -> D {
	return lhs <> .softline <> rhs
}
public func <+/+> (lhs: Document, rhs: Document) -> Document {
	return lhs <> .softline <> rhs
}

///
/// `<-/->` `.softbreak` encloses in `lhs` and `rhs`.
/// `.softbreak` behaves like a empty (-), if the resulting output fits the page,
/// otherwise it behaves like a `linebreak` (/-)
///
public func <-/-> <D: DocumentType>(lhs: D, rhs: D) -> D {
	return lhs <> .softbreak <> rhs
}
public func <-/-> (lhs: Document, rhs: Document) -> Document {
	return lhs <> .softbreak <> rhs
}