//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

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

public func prettyString(rule: RenderingRule, width: Int, doc: () -> Document) -> String {
	return prettyDocument(rule, width: width, doc: doc).description
}

public func prettyString(rule: RenderingRule, width: Int, doc: Document) -> String {
	return prettyDocument(rule, width: width, doc: doc).description
}

internal func prettyDocument(rule: RenderingRule, width: Int, doc: () -> Document) -> RenderedDocument {
	return prettyDocument(rule, width: width, doc: doc())
}

internal func prettyDocument(rule: RenderingRule, width: Int, doc: Document) -> RenderedDocument {
	fatalError()
}
