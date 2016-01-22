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

