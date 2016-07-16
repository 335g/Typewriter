//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

func spaces(_ n: Int) -> String {
	guard n > 0 else {
		return ""
	}
	
	var str = ""
	for _ in 1...n {
		str = str + " "
	}
	
	return str
}

func indentation(_ n: Int) -> String {
	return spaces(n)
}

func flip<A, B, C>(_ f: (A) -> (B) -> C) -> (B) -> (A) -> C {
	return { b in { a in return f(a)(b) }}
}

func curry<A, B, C>(_ f: (A, B) -> C) -> (A) -> (B) -> C {
	return { a in { b in f(a, b) } }
}

func uncurry<A, B, C>(_ f: (A) -> (B) -> C) -> (A, B) -> C {
	return { f($0)($1) }
}

func zipWith<A: Collection, B: Collection, C>(_ f: (A.Iterator.Element) -> (B.Iterator.Element) -> C) -> (A) -> (B) -> [C] {
	return { a in
		{ b in
			return zip(a, b).map{ f($0)($1) }
		}
	}
}

func fix<T, U>(_ f: ((T) -> U) -> (T) -> U) -> (T) -> U {
	return { f(fix(f))($0) }
}
