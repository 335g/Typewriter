//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - RenderedDocument

public indirect enum RenderedDocument: CustomStringConvertible {
	case Fail
	case Empty
	case Char(Character, RenderedDocument)
	case Text(String, RenderedDocument)
	case Line(Int, RenderedDocument)
}

// MARK: RenderedDocument : CustomStringConvertible

extension RenderedDocument {
	public var description: String {
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
}


