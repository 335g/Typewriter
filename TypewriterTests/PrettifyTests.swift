//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

import XCTest
import Assertions
import BaseKit
@testable import Typewriter

final class PrettifyTests: XCTestCase {
	
	// MARK: flatten
	func testPrettyStringFlattenProduceString(){
		var result, str: String
		
		result = prettyString {
			return Document.FlatAlt("a", "b").flatten()
		}
		str = "b"
		assertEqual(result, str)
		
		result = prettyString {
			return ("a" </+> "b" </-> "c").flatten()
		}
		str = "a bc"
		assertEqual(result, str)
	}
	
	// MARK: group
	func testPrettyStringGroupProduceString(){
		var result, str: String
		let doc: Document = ((("a" </+> "b").group() </+> "c").group() </+> "d").group()
		
		result = doc.prettify(width: 30)
		str = "a b c d"
		assertEqual(result, str)
		
		result = doc.prettify(width: 6)
		str = "a b c\nd"
		assertEqual(result, str)
		
		result = doc.prettify(width: 4)
		str = "a b\nc\nd"
		assertEqual(result, str)
		
		result = doc.prettify(width: 2)
		str = "a\nb\nc\nd"
		assertEqual(result, str)
	}
	
	// MARK: align
	func testPrettyStringAlignProduceAlignedString(){
		let result = prettyString {
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
		let result = prettyString(width: 15) {
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
	func testPrettyStringIndentProduceIndentedString(){
		let result = prettyString(width: 15){
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
	func testPrettyStringEncloseProduceEnclosedString(){
		let result = prettyString {
			return Document.char("a").enclose(open: .lparen, close: .rparen)
		}
		let str = "(a)"
		assertEqual(result, str)
	}
	
	// MARK: beside (<>)
	func testPrettyStringBesideProduceCombinedString(){
		let result = prettyString {
			return "a" <> "b"
		}
		let str = "ab"
		assertEqual(result, str)
	}
	
	// MARK: space (<+>)
	func testPrettyStringSpaceProducePutSpaceDocument(){
		let result = prettyString {
			return "a" <+> "b"
		}
		let str = "a b"
		assertEqual(result, str)
	}
	
	// MARK: line (</+>)
	func testPrettyStringLineProduceWithLineDocument(){
		var result, str: String
		
		result = prettyString {
			return "a" </+> "b"
		}
		str = "a\nb"
		assertEqual(result, str)
		
		result = prettyString {
			return ("a" </+> "b").group()
		}
		str = "a b"
		assertEqual(result, str)
	}
	
	// MARK: linebreak (</->)
	func testPrettyStringLinebreakProduceWithLinebreakDocument(){
		var result, str: String
		
		result = prettyString {
			return "a" </-> "b"
		}
		str = "a\nb"
		assertEqual(result, str)
		
		result = prettyString {
			return ("a" </-> "b").group()
		}
		str = "ab"
		assertEqual(result, str)
	}
	
	// MARK: softline (<+/+>)
	func testPrettyStringSoftlineProduceWidthLineDocument(){
		var result, str: String
		let doc: Document = "a" <+/+> "b" <+/+> "c" <+/+> "d"
		
		result = doc.prettify(width: 30)
		str = "a b c d"
		assertEqual(result, str)
		
		result = doc.prettify(width: 6)
		///          | boundary (6)
		str = "a b c\n"
			+ "d"
		assertEqual(result, str)
		
		result = doc.prettify(width: 4)
		///        | boundary (4)
		str = "a b\n"
			+ "c d"
		assertEqual(result, str)
		
		result = doc.prettify(width: 2)
		///      | boundary (2)
		str = "a\n"
			+ "b\n"
			+ "c\n"
			+ "d"
		assertEqual(result, str)
	}
	
	// MARK: softbreak (<-/->)
	func testPrettyStringSoftbreakProduceWidthLinebreakDocument(){
		var result, str: String
		let doc: Document = "a" <-/-> "b" <-/-> "c" <-/-> "d"
		
		result = doc.prettify(width: 30)
		str = "abcd"
		assertEqual(result, str)
		
		result = doc.prettify(width: 3)
		///       | boundary (3)
		str = "abc\n"
			+ "d"
		assertEqual(result, str)
		
		result = doc.prettify(width: 2)
		///      | boundary (2)
		str = "ab\n"
			+ "cd"
		assertEqual(result, str)
		
		result = doc.prettify(width: 1)
		///     | boundary (1)
		str = "a\n"
			+ "b\n"
			+ "c\n"
			+ "d"
		assertEqual(result, str)
	}
	
	// MARK: hcat
	func testPrettyStringHcatProduceFoldedString(){
		var result, str: String
		
		result = prettyString(doc: [].hcat())
		str = ""
		assertEqual(result, str)
		
		result = prettyString(doc: ["a"].hcat())
		str = "a"
		assertEqual(result, str)
		
		result = prettyString(doc: ["a", "b"].hcat())
		str = "ab"
		assertEqual(result, str)
		
		result = prettyString(doc: ["a", "b", "c"].hcat())
		str = "abc"
		assertEqual(result, str)
	}
	
	// MARK: vcat
	func testPrettyStringVcatProduceFoldedString(){
		var result, str: String
		
		result = prettyString(doc: [].vcat())
		str = ""
		assertEqual(result, str)
		
		result = prettyString(doc: ["a"].vcat())
		str = "a"
		assertEqual(result, str)
		
		result = prettyString(doc: ["a", "b"].vcat())
		str = "a\nb"
		assertEqual(result, str)
		
		result = prettyString(doc: ["a", "b", "c"].vcat())
		str = "a\nb\nc"
		assertEqual(result, str)
		
		/// group
		result = prettyString {
			let folded: Document = ["a", "b", "c"].vcat()
			return folded.group()
		}
		str = "abc"
		assertEqual(result, str)
	}
	
	// MARK: cat
	func testPrettyStringCatProduceFoldedString(){
		var result, str: String
		
		/// Yes Fits
		result = prettyString(width: 30, doc: [].cat())
		str = ""
		assertEqual(result, str)
		
		result = prettyString(width: 30, doc: ["a"].cat())
		str = "a"
		assertEqual(result, str)
		
		result = prettyString(width: 30, doc: ["a", "b"].cat())
		str = "ab"
		assertEqual(result, str)
		
		result = prettyString(width: 30, doc: ["a", "b", "c"].cat())
		str = "abc"
		assertEqual(result, str)
		
		
		/// No Fits
		result = prettyString(width: 0, doc: ["a", "b"].cat())
		str = "a\nb"
		assertEqual(result, str)
		
		result = prettyString(width: 2, doc: ["a", "b", "c"].cat())
		str = "a\nb\nc"
		assertEqual(result, str)
	}
	
	// MARK: fillCat
	func testPrettyStringFillCatProduceFoldedString(){
		var result, str: String
		
		/// Yes Fits
		result = prettyString(width: 30, doc: [].fillCat())
		str = ""
		assertEqual(result, str)
		
		result = prettyString(width: 30, doc: ["a"].fillCat())
		str = "a"
		assertEqual(result, str)
		
		result = prettyString(width: 30, doc: ["a", "b"].fillCat())
		str = "ab"
		assertEqual(result, str)
		
		result = prettyString(width: 30, doc: ["a", "b", "c"].fillCat())
		str = "abc"
		assertEqual(result, str)
		
		
		/// No Fits
		result = prettyString(width: 0, doc: ["a", "b"].fillCat())
		str = "a\nb"
		assertEqual(result, str)
		
		result = prettyString(width: 2, doc: ["a", "b", "c"].fillCat())
		str = "ab\nc"
		assertEqual(result, str)
	}
	
	// MARK: hsep
	func testPrettyStringHsepProduceFoldedString(){
		var result, str: String
		
		result = prettyString(width: 30, doc: [].hsep())
		str = ""
		assertEqual(result, str)
		
		result = prettyString(width: 30, doc: ["a"].hsep())
		str = "a"
		assertEqual(result, str)
		
		result = prettyString(width: 30, doc: ["a", "b"].hsep())
		str = "a b"
		assertEqual(result, str)
		
		result = prettyString(width: 30, doc: ["a", "b", "c"].hsep())
		str = "a b c"
		assertEqual(result, str)
	}
	
	// MARK: vsep
	func testPrettyStringVsepProduceFoldedString(){
		var result, str: String
		
		result = prettyString(width: 30, doc: [].vsep())
		str = ""
		assertEqual(result, str)
		
		result = prettyString(width: 30, doc: ["a"].vsep())
		str = "a"
		assertEqual(result, str)
		
		result = prettyString(width: 30, doc: ["a", "b"].vsep())
		str = "a\nb"
		assertEqual(result, str)
		
		result = prettyString(width: 30, doc: ["a", "b", "c"].vsep())
		str = "a\nb\nc"
		assertEqual(result, str)
		
		
		/// group
		result = prettyString(width: 30){
			let folded: Document = ["a", "b", "c"].vsep()
			return folded.group()
		}
		str = "a b c"
		assertEqual(result, str)
	}
	
	// MARK: sep
	func testPrettyStringSepProduceFoldedString(){
		var result, str: String
		
		/// Yes Fits
		result = prettyString(width: 30, doc: [].sep())
		str = ""
		assertEqual(result, str)
		
		result = prettyString(width: 30, doc: ["a"].sep())
		str = "a"
		assertEqual(result, str)
		
		result = prettyString(width: 30, doc: ["a", "b"].sep())
		str = "a b"
		assertEqual(result, str)
		
		result = prettyString(width: 30, doc: ["a", "b", "c"].sep())
		str = "a b c"
		assertEqual(result, str)
		
		
		/// No Fits
		result = prettyString(width: 0, doc: ["a", "b"].sep())
		str = "a\nb"
		assertEqual(result, str)
		
		result = prettyString(width: 3, doc: ["a", "b", "c"].sep())
		str = "a\nb\nc"
		assertEqual(result, str)
	}
	
	// MARK: fillSep
	func testPrettyStringFillSepProduceFoldedString(){
		var result, str: String
		
		/// Yes Fits
		result = prettyString(width: 30, doc: [].fillSep())
		str = ""
		assertEqual(result, str)
		
		result = prettyString(width: 30, doc: ["a"].fillSep())
		str = "a"
		assertEqual(result, str)
		
		result = prettyString(width: 30, doc: ["a", "b"].fillSep())
		str = "a b"
		assertEqual(result, str)
		
		result = prettyString(width: 30, doc: ["a", "b", "c"].fillSep())
		str = "a b c"
		assertEqual(result, str)
		
		
		/// No Fits
		result = prettyString(width: 0, doc: ["a", "b"].fillSep())
		str = "a\nb"
		assertEqual(result, str)
		
		result = prettyString(width: 3, doc: ["a", "b", "c"].fillSep())
		str = "a b\nc"
		assertEqual(result, str)
	}
	
	// MARK: encloseSep
	func testPrettyStringEncloseSepProduceFoldedString(){
		var result, str: String
		
		/// Yes Fits
		result = prettyString(width: 30){
			return [].encloseSep(.comma, open: .lparen, close: .rparen)
		}
		str = "()"
		assertEqual(result, str)
		
		result = prettyString(width: 30){
			return ["a"].encloseSep(.comma, open: .lparen, close: .rparen)
		}
		str = "(a)"
		assertEqual(result, str)
		
		result = prettyString(width: 30){
			return ["a", "b", "c"].encloseSep(.comma, open: .lparen, close: .rparen)
		}
		str = "(a,b,c)"
		assertEqual(result, str)
		
		
		/// No Fits
		result = prettyString(width: 10){
			return "prefix" <+> ["100", "1000", "10000"].encloseSep(.comma, open: .lparen, close: .rparen)
		}
		
		///             | boundary (10)
		///             |
		str = "prefix (100\n"
			+ "       ,1000\n"
			+ "       ,10000)"
		
		assertEqual(result, str)
	}
	
	// MARK: encloseSepNest
	func testPrettyStringEncloseSepNestProduceFoldedString(){
		var result, str: String
		
		/// Yes Fits
		result = prettyString(width: 30){
			return [].encloseSepNest(4, sep: .comma, open: .lparen, close: .rparen)
		}
		str = "()"
		assertEqual(result, str)
		
		result = prettyString(width: 30){
			return ["a"].encloseSepNest(4, sep: .comma, open: .lparen, close: .rparen)
		}
		str = "(a)"
		assertEqual(result, str)
		
		result = prettyString(width: 30){
			return ["a", "b", "c"].encloseSepNest(4, sep: .comma, open: .lparen, close: .rparen)
		}
		str = "(a, b, c)"
		assertEqual(result, str)
		
		
		/// No Fits
		result = prettyString(width: 10){
			return "prefix" <+> ["100", "1000", "10000"].encloseSepNest(2, sep: .comma, open: .lparen, close: .rparen)
		}
		
		///             | boundary (10)
		///             |
		str = "prefix (\n"
			+ "         100,\n"
			+ "         1000,\n"
			+ "         10000\n"
			+ "       )"
		
		assertEqual(result, str)
	}
	
	// MARK: prettify (Dictionary)
	func testPrettyStringDictPrettifyProduceFoldedString(){
		var result, str: String
		var dict: Dictionary<String, String>
		
		/// Yes Fits
		
		dict = [:]
		result = prettyString(width: 30){
			return dict.prettify(4)
		}
		str = "[]"
		assertEqual(result, str)
		
		dict = ["a": "a0"]
		result = prettyString(width: 30){
			return dict.prettify(4)
		}
		str = "[a: a0]"
		assertEqual(result, str)
		
		dict = ["a": "a0", "c": "c0", "b": "b0"]
		result = prettyString(width: 30){
			return dict.prettify(4)
		}
		str = "[a: a0, b: b0, c: c0]"
		assertEqual(result, str)
		
		/// No Fits
		
		result = prettyString(width: 10){
			return "prefix" <+> dict.prettify(2)
		}
		///             | boundary (10)
		///             |
		str = "prefix [\n"
			+ "         a: a0,\n"
			+ "         b: b0,\n"
			+ "         c: c0\n"
			+ "       ]"
		assertEqual(result, str)
	}
	
	// MARK: style
	func testPrettyStringIntensityProduceString(){
		var result, str: String
		let escape = "\u{001B}["
		let suffix = escape + "0m"
		var doc: Document
		
		doc = "a" <+> "b"
		result = doc.intensity(.Bold).prettify(width: 30)
		str = escape + "1m" + "a b" + suffix
		assertEqual(result, str)
		
		doc = ("a" <+> "b").underline(.Single) <> "c"
		result = doc.prettify(width: 30)
		str = escape + "4m" + "a b" + suffix + "c"
		assertEqual(result, str)
	}
	
}
