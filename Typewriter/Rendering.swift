//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

import Prelude

// MARK: - RenderedDocument

indirect enum RenderedDocument: CustomStringConvertible {
	case Fail
	case Empty
	case Char(Character, RenderedDocument)
	case Text(String, RenderedDocument)
	case Line(Int, RenderedDocument)
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
		}
	}
}

// MARK: - RenderingRule

public enum RenderingRule {
	case Oneline
	case EndIndentation
	
	internal func fits(width: Int, nesting: Int, rest: Int, document: RenderedDocument) -> Bool {
		guard rest >= 0 else {
			return false
		}
		
		switch document {
		case .Fail:
			return false
		case .Empty:
			return true
		case let .Char(_, doc):
			return fits(width, nesting: nesting, rest: rest - 1, document: doc)
		case let .Text(s, doc):
			return fits(width, nesting: nesting, rest: rest - s.characters.count, document: doc)
		case let .Line(i, doc):
			switch self {
			case .Oneline:
				return true
			case .EndIndentation:
				if nesting < i {
					return fits(width, nesting: nesting, rest: width - i, document: doc)
				}else {
					return true
				}
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
	public func prettyString(rule: RenderingRule, width: Int) -> String {
		return self.prettyDocument(rule, width: width).description
	}
	
	internal func prettyDocument(rule: RenderingRule, width: Int) -> RenderedDocument {
		let nicest: (Int, Int, RenderedDocument, RenderedDocument) -> RenderedDocument = { indentation, column, doc1, doc2 in
			if rule.fits(width, nesting: min(indentation, column), rest: width - column, document: doc1) {
				return doc1
			}else {
				return doc2
			}
		}
		let best: (Int, Int, Docs) -> RenderedDocument = fix{ best in
			{ indentation, column, docs in
				switch docs {
				case .Nil:
					return .Empty
				case let .Cons(i, d, ds):
					switch d {
					case .Fail:
						return .Fail
					case .Empty:
						return best(indentation, column, ds)
					case let .Char(c):
						return .Char(c, best(indentation, column + 1, ds))
					case let .Text(str):
						return .Text(str, best(indentation, column + str.characters.count, ds))
					case .Line:
						return .Line(i, best(i, i, ds))
					case let .FlatAlt(x, _):
						return best(indentation, column, .Cons(i, x, ds))
					case let .Cat(x, y):
						return best(indentation, column, .Cons(i, x, .Cons(i, y, ds)))
					case let .Nest(j, x):
						return best(indentation, column, .Cons(i+j, x, ds))
					case let .Union(x, y):
						return nicest(
							indentation,
							column,
							best(indentation, column, .Cons(i, x, ds)),
							best(indentation, column, .Cons(i, y, ds))
						)
					case let .Column(f):
						return best(indentation, column, .Cons(i, f(column), ds))
					case let .Nesting(f):
						return best(indentation, column, .Cons(i, f(i), ds))
					}
				}
			}
		}
		
		return best(0, 0, .Cons(0, self, .Nil))
	}
}

public func prettyString(rule: RenderingRule, width: Int, doc: () -> Document) -> String {
	return doc().prettyString(rule, width: width)
}

internal func prettyDocument(rule: RenderingRule, width: Int, doc: () -> Document) -> RenderedDocument {
	return doc().prettyDocument(rule, width: width)
}

