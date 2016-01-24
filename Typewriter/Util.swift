//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

func spaces(n: Int) -> String {
	guard n > 0 else {
		return ""
	}
	
	var str = ""
	for _ in 1...n {
		str = str + " "
	}
	
	return str
}

func indentation(n: Int) -> String {
	return spaces(n)
}

func fromOptional<T>(x: T) -> T? -> T {
	return { m in
		switch m {
		case .None:
			return x
		case let .Some(a):
			return a
		}
	}
}

func fromOptional<T>(f: (T, T) -> T) -> T -> T? -> T {
	return { x in
		{ m in
			switch m {
			case .None:
				return x
			case let .Some(a):
				return f(x, a)
			}
		}
	}
}