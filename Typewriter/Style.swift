//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

public protocol DocumentStyleType {
	func wrap(str: String) -> String
}

public extension DocumentStyleType {
	public func wrap(str: String) -> String {
		return ""
	}
}

public struct DocumentStyle: DocumentStyleType {
	
}
