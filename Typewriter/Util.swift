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

func flip<A, B, C>(f: A -> B -> C) -> B -> A -> C {
	return { b in { a in return f(a)(b) }}
}

func curry<A, B, C>(f: (A, B) -> C) -> A -> B -> C {
	return { a in { b in f(a, b) } }
}

func uncurry<A, B, C>(f: A -> B -> C) -> (A, B) -> C {
	return { f($0)($1) }
}

func zipWith<A: CollectionType, B: CollectionType, C>(f: A.Generator.Element -> B.Generator.Element -> C) -> A -> B -> [C] {
	return { a in
		{ b in
			return zip(a, b).map{ f($0)($1) }
		}
	}
}

func fix<T, U>(f: (T -> U) -> T -> U) -> T -> U {
	return { f(fix(f))($0) }
}
