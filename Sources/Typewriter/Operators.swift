//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

///
/// + : space
/// - : empty
/// / : line break
///

///
infix operator <> {
	associativity right
	precedence 160
}

/// space
infix operator <+> {
	associativity right
	precedence 160
}

/// line
infix operator </+> {
	associativity right
	precedence 150
}

/// linebreak
infix operator </-> {
	associativity right
	precedence 150
}

/// softline
infix operator <+/+> {
	associativity right
	precedence 150
}

/// softbreak
infix operator <-/-> {
	associativity right
	precedence 150
}
