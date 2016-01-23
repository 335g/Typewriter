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
	
	// MARK: enclose
	func testDocumentEncloseProduceEnclosedString(){
		let result = prettyString(.Oneline, width: 30){
			return Document.char("a").enclose(open: .lparen, close: .rparen)
		}
		
		let str = "(a)"
		
		assertEqual(result, str)
	}
	
	// MARK: beside (<>)
	func testDocumentBesideProduceCombinedString(){
		let result1 = prettyString(.Oneline, width: 30){
			return "a" <> "b"
		}
		let result2 = prettyString(.Oneline, width: 30){
			let a = Document.char("a")
			return a.beside("b")
		}
		
		let str = "ab"
		
		assertEqual(result1, str)
		assertEqual(result2, str)
	}
	
	// MARK: space (<+>)
	func testDocumentSpaceProducePutSpaceDocument(){
		let result1 = prettyString(.Oneline, width: 30){
			return "a" <+> "b"
		}
		let result2 = prettyString(.Oneline, width: 30){
			return "a" <> .space <> "b"
		}
		
		let str = "a b"
		
		assertEqual(result1, str)
		assertEqual(result2, str)
	}
	
	// MARK: line (</+>)
	func testDocumentLineProduceWithLineDocument(){
		let result1 = prettyString(.Oneline, width: 30){
			return "a" </+> "b"
		}
		let str1 = "a\nb"
		assertEqual(result1, str1)
		
		
		let result2 = prettyString(.Oneline, width: 30){
			return (Document.char("a") </+> Document.char("b")).group()
		}
		let str2 = "a b"
		assertEqual(result2, str2)
	}
}
