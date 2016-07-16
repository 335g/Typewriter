//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - DocumentType

public protocol DocumentType {
	static var empty: Self { get }
	static func char(_ x: Character) -> Self
	static func text(_ x: String) throws -> Self
	static var hardline: Self { get }
	static var line: Self { get }
	static var linebreak: Self { get }
	static func union(_ x: Self, _ y: Self) -> Self
	static func column(f: (Int) -> Self) -> Self
	static func nesting(f: (Int) -> Self) -> Self
	func nest(_ i: Int) -> Self
	func flatten() -> Self
	func beside(_ other: Self) -> Self
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
	
	public static func string(_ str: String) -> Self {
		return str.characters
			.split{ $0 == "\n" }
			.map{ try! Self.text(String($0)) }
			.vsep()
	}
	
	public static func texts(_ str: String) -> [Self] {
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
	public func enclosed(open: Self, close: Self) -> Self {
		return open <> self <> close
	}
	
	public func squotes() -> Self { return enclosed(open: .squote, close: .squote) }
	public func dquotes() -> Self { return enclosed(open: .dquote, close: .dquote) }
	public func parens() -> Self { return enclosed(open: .lparen, close: .rparen) }
	public func braces() -> Self { return enclosed(open: .lbrace, close: .rbrace) }
	public func angles() -> Self { return enclosed(open: .langle, close: .rangle) }
	public func brackets() -> Self { return enclosed(open: .lbracket, close: .rbracket) }
	
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
	public func enclosed(nest i: Int, open: Self, close: Self) -> Self {
		return ((open <-/-> self).hang(i) <-/-> close).align()
	}
	
	public func squotesNest(_ i: Int) -> Self { return enclosed(nest: i, open: .squote, close: .squote) }
	public func dquotesNest(_ i: Int) -> Self { return enclosed(nest: i, open: .dquote, close: .dquote) }
	public func parensNest(_ i: Int) -> Self { return enclosed(nest: i, open: .lparen, close: .rparen) }
	public func bracesNest(_ i: Int) -> Self { return enclosed(nest: i, open: .lbrace, close: .rbrace) }
	public func anglesNest(_ i: Int) -> Self { return enclosed(nest: i, open: .langle, close: .rangle) }
	public func bracketsNest(_ i: Int) -> Self { return enclosed(nest: i, open: .lbracket, close: .rbracket) }
	
	///
	/// `align` renders document with the nesting level set to current column.
	///
	public func align() -> Self {
		return .column(f: { k in
			.nesting(f: { i in self.nest(k - i) })
		})
	}
	
	///
	/// `hang` implements hanging indentation.
	/// Document obtained renders document with a nesting level set to the indentation for some text.
	///
	public func hang(_ i: Int) -> Self {
		return self.nest(i).align()
	}
	
	///
	/// `indent` indents document with `i` spaces.
	///
	public func indent(_ i: Int) -> Self {
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

// MARK: - Document

public indirect enum Document: DocumentType, StringLiteralConvertible, Equatable {
	case fail
	case emptyDoc
	case charDoc(Character)
	case textDoc(String)
	case lineDoc
	case catDoc(Document, Document)
	case flatAltDoc(Document, Document)
	case unionDoc(Document, Document)
	case nestDoc(Int, Document)
	case Nesting((Int) -> Document)
	case Column((Int) -> Document)
	case Style(DocumentStyle, Document)
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

// MARK: Document : DocumentType

extension Document {
	
	// MARK: Document.ConstructError (ErrorType)
	public enum ConstructError: ErrorProtocol {
		case ContainsLinebreak
	}
	
	public static var empty: Document {
		return .emptyDoc
	}
	
	public static func char(_ x: Character) -> Document {
		switch x {
		case "\n":
			return .lineDoc
			
		default:
			return .charDoc(x)
		}
	}
	
	public static func text(_ x: String) throws -> Document {
		switch x {
		case "":
			return .empty
		default:
			if x.characters.contains("\n") {
				throw Document.ConstructError.ContainsLinebreak
			}else {
				return .textDoc(x)
			}
		}
	}
	
	public static var hardline: Document {
		return .lineDoc
	}
	
	public static var line: Document {
		return .flatAltDoc(.hardline, .space)
	}
	
	public static var linebreak: Document {
		return .flatAltDoc(.hardline, .empty)
	}
	
	public static func union(_ x: Document, _ y: Document) -> Document {
		return .unionDoc(x, y)
	}
	
	public static func column(f: (Int) -> Document) -> Document {
		return .Column(f)
	}
	
	public static func nesting(f: (Int) -> Document) -> Document {
		return .Nesting(f)
	}
	
	public func nest(_ i: Int) -> Document {
		return .nestDoc(i, self)
	}
	
	public func flatten() -> Document {
		switch self {
		case let .catDoc(x, y):
			return .catDoc(x.flatten(), y.flatten())
		case let .flatAltDoc(_, x):
			return x
		case .lineDoc:
			return .fail
		case let .unionDoc(x, _):
			return x.flatten()
		default:
			return self
		}
	}
	
	public func beside(_ doc: Document) -> Document {
		return .catDoc(self, doc)
	}
}

// MARK: Document (Style)

extension Document {
	
	func style(_ x: DocumentStyle) -> Document {
		switch self {
		case let .Style(s, doc):
			return .Style(s.merge(x), doc)
		default:
			return .Style(x, self)
		}
	}
	
	public func intensity(x: DocumentStyle.Intensity) -> Document {
		return self.style(DocumentStyle(intensity: x))
	}
	
	public func underline(x: DocumentStyle.Underline) -> Document {
		return style(DocumentStyle(underline: x))
	}
	
	public func blink(x: DocumentStyle.Blink) -> Document {
		return style(DocumentStyle(blink: x))
	}
	
	public func color(x: DocumentStyle.Color) -> Document {
		return style(DocumentStyle(color: x))
	}
	
	public func plain() -> Document {
		switch self {
		case let .catDoc(x, y):
			return .catDoc(x.plain(), y.plain())
		case let .flatAltDoc(x, y):
			return .flatAltDoc(x.plain(), y.plain())
		case let .unionDoc(x, y):
			return .unionDoc(x.plain(), y.plain())
		case let .nestDoc(i, x):
			return .nestDoc(i, x.plain())
		case let .Nesting(f):
			return .Nesting({ f($0).plain() })
		case let .Column(f):
			return .Column({ f($0).plain() })
		case let .Style(_, x):
			return x.plain()
		default:
			return self
		}
	}
}

// MARK: Document : Equatable

public func == (lhs: Document, rhs: Document) -> Bool {
	switch (lhs, rhs) {
	case (.fail, .fail):
		return true
	case (.emptyDoc, .emptyDoc):
		return true
	case let (.charDoc(l), .charDoc(r)):
		return l == r
	case let (.textDoc(l), .textDoc(r)):
		return l == r
	case (.lineDoc, .lineDoc):
		return true
	case let (.nestDoc(li, ldoc), .nestDoc(ri, rdoc)):
		return li == ri && ldoc == rdoc
	case let (.catDoc(lx, ly), .catDoc(rx, ry)):
		return lx == rx && ly == ry
	case let (.flatAltDoc(lx, ly), .flatAltDoc(rx, ry)):
		return lx == rx && ly == ry
	case let (.unionDoc(lx, ly), .unionDoc(rx, ry)):
		return lx == rx && ly == ry
	case let (.Column(lf), .Column(rf)):
		return lf(4) == rf(4)
	case let (.Nesting(lf), .Nesting(rf)):
		return lf(4) == rf(4)
	case let (.Style(ls, ldoc), .Style(rs, rdoc)):
		return ls == rs && ldoc == rdoc
	default:
		return false
	}
}

// MARK: - extension CollectionType where Generator.Element: DocumentType

enum FoldableError: ErrorProtocol {
	case OnlyOne
}

public extension Collection where Iterator.Element: DocumentType {
	typealias Element = Iterator.Element
	
	func foldr<T>(initial: T, f: (Element) -> (T) -> T) -> T {
		return reversed().reduce(initial, combine: uncurry(flip(f)))
	}
	
	func foldr1(_ f: (Element) -> (Element) -> Element) throws -> Element {
		let ifNotOptional: (Element) -> (Element?) -> Element = { x in
			{ y in
				switch y {
				case .none:
					return x
				case let .some(a):
					return f(x)(a)
				}
			}
		}
		
		guard let folded = foldr(initial: nil, f: ifNotOptional) else {
			throw FoldableError.OnlyOne
		}
		
		return folded
	}
	
	func fold(_ f: (Element, Element) -> Element) -> Element {
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
	public func enclosed(separator: Element, open: Element, close: Element) -> Element {
		guard let first = self.first else {
			return open <> close
		}
		
		guard self.count != 1 else {
			return open <> first <> close
		}
		
		let count: Int = self.count as! Int
		var separators = Array(repeating: separator, count: count - 1)
		separators.insert(open, at: 0)
		
		return (zipWith(curry(<>))(separators)(self).cat() <> close).align()
	}
	
	///
	/// comma separates the documents.
	/// And encloses them in square brackets.
	///
	public func list() -> Element {
		return enclosed(separator: .comma, open: .lbracket, close: .rbracket)
	}
	
	///
	/// comma separates the documents.
	/// And encloses them in parenthesis.
	///
	public func tuple() -> Element {
		return enclosed(separator: .comma, open: .lparen, close: .rparen)
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
	///   [100, 1000, 10000]
	///
	/// ** if not fits **
	///   [\n
	///     100,\n
	///     1000,\n
	///     10000
	///   ]\n
	///
	public func enclosed(nest: Int, separator: Element, open: Element, close: Element) -> Element {
		guard let first = self.first else {
			return open <> close
		}
		
		guard self.count != 1 else {
			return first.enclosed(nest: nest, open: open, close: close)
		}
		
		return self.fold({ $0 <> separator <+/+> $1 }).enclosed(nest: nest, open: open, close: close)
	}
}

// MARK: - extension Dictionary where Key: Typewritable, Key: Comparable, Value: Typewritable

public extension Dictionary where Key: DocumentConvertible, Key: Comparable, Value: DocumentConvertible {
	
	func enclosed(nest: Int, separator: Document, open: Document, close: Document) -> Document {
		return self
			.sorted(isOrderedBefore: { $0.0 < $1.0 })
			.map{ $0.document <> .colon <> .space <> $1.document }
			.enclosed(nest: nest, separator: separator, open: open, close: close)
	}
	
	///
	/// equal encloseSepNest (CollectionType)
	///
	public func prettify(nest: Int) -> Document {
		return enclosed(nest: nest, separator: .comma, open: .lbracket, close: .rbracket)
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
