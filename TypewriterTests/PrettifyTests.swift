//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

import XCTest
import Assertions
import Prelude
@testable import Typewriter

final class PrettifyTests: XCTestCase {
	
	func testPrettyStringCharProduceChar(){
		let a = prettyString(.Oneline, width: 40){
			return .char("a")
		}
		let b = "a"
		assertEqual(a, b)
	}
	
	func testPrettyStringStringProduceString(){
		let a = prettyString(.Oneline, width: 40){
			return "abc"
		}
		let b = "abc"
		assertEqual(a, b)
	}
	
	// MARK: align
	func testPrettyStringAlignProduceAlignedString(){
		let result = prettyString(.Oneline, width: 40){
			return "This is a" <+> Document.texts("test for align combinator.")
				.vsep()
				.align()
		}
		let str = ""
			+ "This is a test\n"
			+ "          for\n"
			+ "          align\n"
			+ "          combinator."
		assertEqual(result, str)
	}
	
	// MARK: hang
	func testPrettyStringHangProduceHangedString(){
		let result = prettyString(.Oneline, width: 15){
			return Document.texts("This is a test for hang combinator.")
				.fillSep()
				.hang(4)
		}
		
		///                   | boundary (15)
		///                   |
		let str = ""
			+ "This is a test\n"
			+ "    for hang\n"
			+ "    combinator."
		
		assertEqual(result, str)
	}
	
	// MARK: indent
	func testDocumentIndentProduceIndentedString(){
		let result = prettyString(.Oneline, width: 15){
			return Document.texts("This is a test for hang combinator.")
				.fillSep()
				.indent(4)
		}
		
		///                   | boundary (15)
		///                   |
		let str = ""
			+ "    This is a\n"
			+ "    test for\n"
			+ "    hang\n"
			+ "    combinator."
		
		assertEqual(result, str)
	}
}
