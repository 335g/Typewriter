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
		let result = prettyString(.Oneline, width: 30){
			return "a" <> "b"
		}
		let str = "ab"
		
		assertEqual(result, str)
	}
	
	// MARK: space (<+>)
	func testDocumentSpaceProducePutSpaceDocument(){
		let result = prettyString(.Oneline, width: 30){
			return "a" <+> "b"
		}
		let str = "a b"
		assertEqual(result, str)
	}
	
	// MARK: line (</+>)
	func testDocumentLineProduceWithLineDocument(){
		var result, str: String
		
		result = prettyString(.Oneline, width: 30){
			return "a" </+> "b"
		}
		str = "a\nb"
		assertEqual(result, str)
		
		result = prettyString(.Oneline, width: 30){
			return ("a" </+> "b").group()
		}
		str = "a b"
		assertEqual(result, str)
	}
	
	// MARK: linebreak (</->)
	func testDocumentLinebreakProduceWithLinebreakDocument(){
		var result, str: String
		
		result = prettyString(.Oneline, width: 30){
			return "a" </-> "b"
		}
		str = "a\nb"
		assertEqual(result, str)
		
		result = prettyString(.Oneline, width: 30){
			return ("a" </-> "b").group()
		}
		str = "ab"
		assertEqual(result, str)
	}
	
	// MARK: hcat
	func testDocumentHcatProduceFoldedString(){
		var result, str: String
		
		result = prettyString(.Oneline, width: 30, doc: [].hcat())
		str = ""
		assertEqual(result, str)
		
		result = prettyString(.Oneline, width: 30, doc: ["a"].hcat())
		str = "a"
		assertEqual(result, str)
		
		result = prettyString(.Oneline, width: 30, doc: ["a", "b"].hcat())
		str = "ab"
		assertEqual(result, str)
		
		result = prettyString(.Oneline, width: 30, doc: ["a", "b", "c"].hcat())
		str = "abc"
		assertEqual(result, str)
	}
	
	// MARK: vcat
	func testDocumentVcatProduceFoldedString(){
		var result, str: String
		
		result = prettyString(.Oneline, width: 30, doc: [].vcat())
		str = ""
		assertEqual(result, str)
		
		result = prettyString(.Oneline, width: 30, doc: ["a"].vcat())
		str = "a"
		assertEqual(result, str)
		
		result = prettyString(.Oneline, width: 30, doc: ["a", "b"].vcat())
		str = "a\nb"
		assertEqual(result, str)
		
		result = prettyString(.Oneline, width: 30, doc: ["a", "b", "c"].vcat())
		str = "a\nb\nc"
		assertEqual(result, str)
		
		// group
		result = prettyString(.Oneline, width: 30){
			let folded: Document = ["a", "b", "c"].vcat()
			return folded.group()
		}
		str = "abc"
		assertEqual(result, str)
	}
	
	// MARK: cat
	func testDocumentCatProduceFoldedString(){
		var result, str: String
		
		// Yes Fits
		result = prettyString(.Oneline, width: 30, doc: [].cat())
		str = ""
		assertEqual(result, str)
		
		result = prettyString(.Oneline, width: 30, doc: ["a"].cat())
		str = "a"
		assertEqual(result, str)
		
		result = prettyString(.Oneline, width: 30, doc: ["a", "b"].cat())
		str = "ab"
		assertEqual(result, str)
		
		result = prettyString(.Oneline, width: 30, doc: ["a", "b", "c"].cat())
		str = "abc"
		assertEqual(result, str)
		
		
		// No Fits
		result = prettyString(.Oneline, width: 0, doc: ["a", "b"].cat())
		str = "a\nb"
		assertEqual(result, str)
		
		result = prettyString(.Oneline, width: 2, doc: ["a", "b", "c"].cat())
		str = "a\nb\nc"
		assertEqual(result, str)
	}
	
	// MARK: fillCat
	func testDocumentFillCatProduceFoldedString(){
		var result, str: String
		
		// Yes Fits
		result = prettyString(.Oneline, width: 30, doc: [].fillCat())
		str = ""
		assertEqual(result, str)
		
		result = prettyString(.Oneline, width: 30, doc: ["a"].fillCat())
		str = "a"
		assertEqual(result, str)
		
		result = prettyString(.Oneline, width: 30, doc: ["a", "b"].fillCat())
		str = "ab"
		assertEqual(result, str)
		
		result = prettyString(.Oneline, width: 30, doc: ["a", "b", "c"].fillCat())
		str = "abc"
		assertEqual(result, str)
		
		
		// No Fits
		result = prettyString(.Oneline, width: 0, doc: ["a", "b"].fillCat())
		str = "a\nb"
		assertEqual(result, str)
		
		result = prettyString(.Oneline, width: 2, doc: ["a", "b", "c"].fillCat())
		str = "ab\nc"
		assertEqual(result, str)
	}
	
	// MARK: hsep
	func testDocumentHsepProduceFoldedString(){
		var result, str: String
		
		result = prettyString(.Oneline, width: 30, doc: [].hsep())
		str = ""
		assertEqual(result, str)
		
		result = prettyString(.Oneline, width: 30, doc: ["a"].hsep())
		str = "a"
		assertEqual(result, str)
		
		result = prettyString(.Oneline, width: 30, doc: ["a", "b"].hsep())
		str = "a b"
		assertEqual(result, str)
		
		result = prettyString(.Oneline, width: 30, doc: ["a", "b", "c"].hsep())
		str = "a b c"
		assertEqual(result, str)
	}
	
	// MARK: vsep
	func testDocumentVsepProduceFoldedString(){
		var result, str: String
		
		result = prettyString(.Oneline, width: 30, doc: [].vsep())
		str = ""
		assertEqual(result, str)
		
		result = prettyString(.Oneline, width: 30, doc: ["a"].vsep())
		str = "a"
		assertEqual(result, str)
		
		result = prettyString(.Oneline, width: 30, doc: ["a", "b"].vsep())
		str = "a\nb"
		assertEqual(result, str)
		
		result = prettyString(.Oneline, width: 30, doc: ["a", "b", "c"].vsep())
		str = "a\nb\nc"
		assertEqual(result, str)
		
		
		// group
		result = prettyString(.Oneline, width: 30){
			let folded: Document = ["a", "b", "c"].vsep()
			return folded.group()
		}
		str = "a b c"
		assertEqual(result, str)
	}
	
	// MARK: sep
	func testDocumentSepProduceFoldedString(){
		var result, str: String
		
		// Yes Fits
		result = prettyString(.Oneline, width: 30, doc: [].sep())
		str = ""
		assertEqual(result, str)
		
		result = prettyString(.Oneline, width: 30, doc: ["a"].sep())
		str = "a"
		assertEqual(result, str)
		
		result = prettyString(.Oneline, width: 30, doc: ["a", "b"].sep())
		str = "a b"
		assertEqual(result, str)
		
		result = prettyString(.Oneline, width: 30, doc: ["a", "b", "c"].sep())
		str = "a b c"
		assertEqual(result, str)
		
		
		// No Fits
		result = prettyString(.Oneline, width: 0, doc: ["a", "b"].sep())
		str = "a\nb"
		assertEqual(result, str)
		
		result = prettyString(.Oneline, width: 3, doc: ["a", "b", "c"].sep())
		str = "a\nb\nc"
		assertEqual(result, str)
	}
	
	// MARK: fillSep
	func testDocumentFillSepProduceFoldedString(){
		var result, str: String
		
		// Yes Fits
		result = prettyString(.Oneline, width: 30, doc: [].fillSep())
		str = ""
		assertEqual(result, str)
		
		result = prettyString(.Oneline, width: 30, doc: ["a"].fillSep())
		str = "a"
		assertEqual(result, str)
		
		result = prettyString(.Oneline, width: 30, doc: ["a", "b"].fillSep())
		str = "a b"
		assertEqual(result, str)
		
		result = prettyString(.Oneline, width: 30, doc: ["a", "b", "c"].fillSep())
		str = "a b c"
		assertEqual(result, str)
		
		
		// No Fits
		result = prettyString(.Oneline, width: 0, doc: ["a", "b"].fillSep())
		str = "a\nb"
		assertEqual(result, str)
		
		result = prettyString(.Oneline, width: 3, doc: ["a", "b", "c"].fillSep())
		str = "a b\nc"
		assertEqual(result, str)
	}
}
