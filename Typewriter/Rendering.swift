//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - RenderedDocument

public indirect enum RenderedDocument {
	case Fail
	case Empty
	case Char(Character, RenderedDocument)
	case Text(String, RenderedDocument)
	case Line(Int, RenderedDocument)
}


