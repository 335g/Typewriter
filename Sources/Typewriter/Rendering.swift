//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - Constant

let ReferenceWidth: Int = 60

// MARK: - RenderedDocument

indirect enum RenderedDocument: CustomStringConvertible {
	case fail
	case empty
	case char(Character, RenderedDocument)
	case text(String, RenderedDocument)
	case line(Int, RenderedDocument)
	case style(DocumentStyle, RenderedDocument, RenderedDocument)
}

// MARK: RenderedDocument : CustomStringConvertible

extension RenderedDocument {
	var description: String {
		switch self {
		case .fail, .empty:
			return ""
		case let .char(c, doc):
			return String(c) + doc.description
		case let .text(s, doc):
			return s + doc.description
		case let .line(i, doc):
			return "\n\(indentation(i))" + doc.description
		case let .style(style, x, y):
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
		case .fail:
			return (rest, false)
		case .empty:
			return (rest, true)
		case let .char(_, doc):
			return fits(width, nesting: nesting, rest: rest - 1, document: doc)
		case let .text(s, doc):
			return fits(width, nesting: nesting, rest: rest - s.characters.count, document: doc)
		case let .line(i, doc):
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
		case let .style(_, doc1, doc2):
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
					return (0, 0, .empty)
				case let .Cons(i, d, ds):
					switch d {
					case .fail:
						return (0, 0, .fail)
						
					case .emptyDoc:
						let x = (indentation, column, ds)
						return best(x)
						
					case let .charDoc(c):
						let x = (indentation, column + 1, ds)
						return (indentation, column + 1, .char(c, best(x).2))
						
					case let .textDoc(str):
						let newColumn = str.characters.count + column
						let x = (indentation, newColumn, ds)
						return (indentation, newColumn, .text(str, best(x).2))
						
					case .lineDoc:
						let x = (i, i, ds)
						return (i, i, .line(i, best(x).2))
						
					case let .flatAltDoc(x, _):
						let y: (Int, Int, Docs) = (indentation, column, .Cons(i, x, ds))
						return best(y)
					
					case let .catDoc(x, y):
						let z: (Int, Int, Docs) = (indentation, column, .Cons(i, x, .Cons(i, y, ds)))
						return best(z)
						
					case let .nestDoc(j, x):
						let y: (Int, Int, Docs) = (indentation, column, .Cons(i + j, x, ds))
						return best(y)
						
					case let .unionDoc(x, y):
						let x2: (Int, Int, Docs) = (indentation, column, .Cons(i, x, ds))
						let y2: (Int, Int, Docs) = (indentation, column, .Cons(i, y, ds))
						let nicest = nicest(
							indentation,
							column,
							best(x2).2,
							best(y2).2
						)
						return (indentation, column, nicest)
						
					case let .columnDoc(f):
						let x: (Int, Int, Docs) = (indentation, column, .Cons(i, f(column), ds))
						return best(x)
						
					case let .nestingDoc(f):
						let x: (Int, Int, Docs) = (indentation, column, .Cons(i, f(i), ds))
						return best(x)
						
					case let .styleDoc(style, x):
						let y: (Int, Int, Docs) = (indentation, column, .Cons(i, x, .Nil))
						let pre = best(y)
						return (indentation, column, .style(style, pre.2, best(pre.0, pre.1, ds).2))
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
