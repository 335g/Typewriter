//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - Constant

let ReferenceWidth: Int = 60

// MARK: - RenderedDocument

indirect enum RenderedDocument: CustomStringConvertible {
	case Fail
	case Empty
	case Char(Character, RenderedDocument)
	case Text(String, RenderedDocument)
	case Line(Int, RenderedDocument)
	case Style(DocumentStyle, RenderedDocument, RenderedDocument)
}

// MARK: RenderedDocument : CustomStringConvertible

extension RenderedDocument {
	var description: String {
		switch self {
		case .Fail, .Empty:
			return ""
		case let .Char(c, doc):
			return String(c) + doc.description
		case let .Text(s, doc):
			return s + doc.description
		case let .Line(i, doc):
			return "\n\(indentation(i))" + doc.description
		case let .Style(style, x, y):
			return style.wrap(x.description) + y.description
		}
	}
}

// MARK: - RenderingRule

public enum RenderingRule {
	case Oneline
	case EndIndentation
	
	internal func fits(_ width: Int, nesting: Int, rest: Int, document: RenderedDocument) -> (Int, Bool) {
		guard rest >= 0 else {
			return (rest, false)
		}
		
		switch document {
		case .Fail:
			return (rest, false)
		case .Empty:
			return (rest, true)
		case let .Char(_, doc):
			return fits(width, nesting: nesting, rest: rest - 1, document: doc)
		case let .Text(s, doc):
			return fits(width, nesting: nesting, rest: rest - s.characters.count, document: doc)
		case let .Line(i, doc):
			switch self {
			case .Oneline:
				return (rest, true)
			case .EndIndentation:
				if nesting < i {
					return fits(width, nesting: nesting, rest: width - i, document: doc)
				}else {
					return (rest, true)
				}
			}
		case let .Style(_, doc1, doc2):
			let (nextRest, fits) = self.fits(width, nesting: nesting, rest: rest, document: doc1)
			if fits {
				return self.fits(width, nesting: nesting, rest: nextRest, document: doc2)
			}else {
				return (rest, false)
			}
		}
	}
}

// MARK: - Rendering

enum Docs {
	case Nil
	indirect case Cons(Int, Document, Docs)
}

extension Document {
	public func prettify(rule: RenderingRule = .Oneline, width: Int = ReferenceWidth) -> String {
		return self.prettyDocument(rule: rule, width: width).description
	}
	
	internal func prettyDocument(rule: RenderingRule = .Oneline, width: Int) -> RenderedDocument {
		let nicest: (Int, Int, RenderedDocument, RenderedDocument) -> RenderedDocument = { indentation, column, doc1, doc2 in
			if rule.fits(width, nesting: min(indentation, column), rest: width - column, document: doc1).1 {
				return doc1
			}else {
				return doc2
			}
		}
		let best: (Int, Int, Docs) -> (Int, Int, RenderedDocument) = fix { best in
			{ indentation, column, docs in
				switch docs {
				case .Nil:
					return (0, 0, .Empty)
				case let .Cons(i, d, ds):
					switch d {
					case .Fail:
						return (0, 0, .Fail)
						
					case .Empty:
						let x = (indentation, column, ds)
						return best(x)
						
					case let .Char(c):
						let x = (indentation, column + 1, ds)
						return (indentation, column + 1, .Char(c, best(x).2))
						
					case let .Text(str):
						let newColumn = str.characters.count + column
						let x = (indentation, newColumn, ds)
						return (indentation, newColumn, .Text(str, best(x).2))
						
					case .Line:
						let x = (i, i, ds)
						return (i, i, .Line(i, best(x).2))
						
					case let .FlatAlt(x, _):
						let y: (Int, Int, Docs) = (indentation, column, .Cons(i, x, ds))
						return best(y)
					
					case let .Cat(x, y):
						let z: (Int, Int, Docs) = (indentation, column, .Cons(i, x, .Cons(i, y, ds)))
						return best(z)
						
					case let .Nest(j, x):
						let y: (Int, Int, Docs) = (indentation, column, .Cons(i + j, x, ds))
						return best(y)
						
					case let .Union(x, y):
						let x2: (Int, Int, Docs) = (indentation, column, .Cons(i, x, ds))
						let y2: (Int, Int, Docs) = (indentation, column, .Cons(i, y, ds))
						let nicest = nicest(
							indentation,
							column,
							best(x2).2,
							best(y2).2
						)
						return (indentation, column, nicest)
						
					case let .Column(f):
						let x: (Int, Int, Docs) = (indentation, column, .Cons(i, f(column), ds))
						return best(x)
						
					case let .Nesting(f):
						let x: (Int, Int, Docs) = (indentation, column, .Cons(i, f(i), ds))
						return best(x)
						
					case let .Style(style, x):
						let y: (Int, Int, Docs) = (indentation, column, .Cons(i, x, .Nil))
						let pre = best(y)
						return (indentation, column, .Style(style, pre.2, best(pre.0, pre.1, ds).2))
					}
				}
			}
		}
		
		return best(0, 0, .Cons(0, self, .Nil)).2
	}
}

public func prettyString(rule: RenderingRule = .Oneline, width: Int = ReferenceWidth, doc: () -> Document) -> String {
	return doc().prettify(rule: rule, width: width)
}

public func prettyString(rule: RenderingRule = .Oneline, width: Int = ReferenceWidth, doc: Document) -> String {
	return doc.prettify(rule: rule, width: width)
}
