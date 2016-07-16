//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

import Quick
import Nimble
@testable import Typewriter

final class PrettifySpec: QuickSpec {
	override func spec() {
		
		// MARK: flatten
		describe("flatten"){
			it("should produce flatten document"){
				var result, str: String
				
				result = prettyString {
					return Document.flatAltDoc("a", "b").flatten()
				}
				str = "b"
				expect(result) == str
				
				result = prettyString {
					return ("a" </+> "b" </-> "c").flatten()
				}
				str = "a bc"
				expect(result) == str
			}
		}
		
		// MARK: group
		describe("group"){
			it("should produce organized document"){
				var result, str: String
				let doc: Document = ((("a" </+> "b").group() </+> "c").group() </+> "d").group()
				
				result = doc.prettify(width: 30)
				str = "a b c d"
				expect(result) == str
				
				result = doc.prettify(width: 6)
				str = "a b c\nd"
				expect(result) == str
				
				result = doc.prettify(width: 4)
				str = "a b\nc\nd"
				expect(result) == str
				
				result = doc.prettify(width: 2)
				str = "a\nb\nc\nd"
				expect(result) == str
			}
		}
		
		// MARK: align
		describe("align"){
			it("should produce aligned document"){
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
				
				expect(result) == str
			}
		}
		
		// MARK: hang
		describe("hang"){
			it("should produce wrapped document"){
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
				
				expect(result) == str
			}
		}
		
		// MARK: indent
		describe("indent"){
			it("should produce indent document"){
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
				
				expect(result) == str
			}
		}
		
		// MARK: enclose
		describe("enclose"){
			it("should produce sandwitched document"){
				let result = prettyString {
					return Document.char("a").enclose(open: .lparen, close: .rparen)
				}
				let str = "(a)"
				expect(result) == str
			}
		}
		
		// beside(<>)
		describe("beside(<>)"){
			it("should produce concatenated document"){
				let result = prettyString {
					return "a" <> "b"
				}
				let str = "ab"
				expect(result) == str
			}
		}
		
		// MARK: space(<+>)
		describe("space(<+>)"){
			it("should produce concatenated document"){
				let result = prettyString {
					return "a" <+> "b"
				}
				let str = "a b"
				expect(result) == str
			}
		}
		
		// MARK: line(</+>)
		describe("line(</+>)"){
			it("should produce concatenated document"){
				var result, str: String
				
				result = prettyString {
					return "a" </+> "b"
				}
				str = "a\nb"
				expect(result) == str
				
				result = prettyString {
					return ("a" </+> "b").group()
				}
				str = "a b"
				expect(result) == str
			}
		}
		
		// MARK: linebreak (</->)
		describe("linebreak (</->)"){
			it("should produce concatenated document"){
				var result, str: String
				
				result = prettyString {
					return "a" </-> "b"
				}
				str = "a\nb"
				expect(result) == str
				
				result = prettyString {
					return ("a" </-> "b").group()
				}
				str = "ab"
				expect(result) == str
			}
		}
		
		// MARK: softline (<+/+>)
		describe("softline (<+/+>)"){
			it("should produce concatenated document"){
				var result, str: String
				let doc: Document = "a" <+/+> "b" <+/+> "c" <+/+> "d"
				
				result = doc.prettify(width: 30)
				str = "a b c d"
				expect(result) == str
				
				result = doc.prettify(width: 6)
				///          | boundary (6)
				str = "a b c\n"
					+ "d"
				expect(result) == str
				
				result = doc.prettify(width: 4)
				///        | boundary (4)
				str = "a b\n"
					+ "c d"
				expect(result) == str
				
				result = doc.prettify(width: 2)
				///      | boundary (2)
				str = "a\n"
					+ "b\n"
					+ "c\n"
					+ "d"
				expect(result) == str
			}
		}
		
		// MARK: softbreak (<-/->)
		describe("softbreak (<-/->)"){
			it("should produce concatenated document"){
				var result, str: String
				let doc: Document = "a" <-/-> "b" <-/-> "c" <-/-> "d"
				
				result = doc.prettify(width: 30)
				str = "abcd"
				expect(result) == str
				
				result = doc.prettify(width: 3)
				///       | boundary (3)
				str = "abc\n"
					+ "d"
				expect(result) == str
				
				result = doc.prettify(width: 2)
				///      | boundary (2)
				str = "ab\n"
					+ "cd"
				expect(result) == str
				
				result = doc.prettify(width: 1)
				///     | boundary (1)
				str = "a\n"
					+ "b\n"
					+ "c\n"
					+ "d"
				expect(result) == str
			}
		}
		
		// MARK: hcat
		describe("hcat"){
			it("should produce concatenated document"){
				var result, str: String
				
				result = prettyString(doc: [].hcat())
				str = ""
				expect(result) == str
				
				result = prettyString(doc: ["a"].hcat())
				str = "a"
				expect(result) == str
				
				result = prettyString(doc: ["a", "b"].hcat())
				str = "ab"
				expect(result) == str
				
				result = prettyString(doc: ["a", "b", "c"].hcat())
				str = "abc"
				expect(result) == str
			}
		}
		
		// MARK: vcat
		describe("vcat"){
			it("should produce concatenated document"){
				var result, str: String
				
				result = prettyString(doc: [].vcat())
				str = ""
				expect(result) == str
				
				result = prettyString(doc: ["a"].vcat())
				str = "a"
				expect(result) == str
				
				result = prettyString(doc: ["a", "b"].vcat())
				str = "a\nb"
				expect(result) == str
				
				result = prettyString(doc: ["a", "b", "c"].vcat())
				str = "a\nb\nc"
				expect(result) == str
				
				/// group
				result = prettyString {
					let folded: Document = ["a", "b", "c"].vcat()
					return folded.group()
				}
				str = "abc"
				expect(result) == str
			}
		}
		
		// MARK: cat
		describe("cat"){
			it("should produce concatenated document"){
				var result, str: String
				
				/// Yes Fits
				result = prettyString(width: 30, doc: [].cat())
				str = ""
				expect(result) == str
				
				result = prettyString(width: 30, doc: ["a"].cat())
				str = "a"
				expect(result) == str
				
				result = prettyString(width: 30, doc: ["a", "b"].cat())
				str = "ab"
				expect(result) == str
				
				result = prettyString(width: 30, doc: ["a", "b", "c"].cat())
				str = "abc"
				expect(result) == str
				
				
				/// No Fits
				result = prettyString(width: 0, doc: ["a", "b"].cat())
				str = "a\nb"
				expect(result) == str
				
				result = prettyString(width: 2, doc: ["a", "b", "c"].cat())
				str = "a\nb\nc"
				expect(result) == str
			}
		}
		
		// MARK: fillCat
		describe("fillCat"){
			it("should produce concatenated document"){
				var result, str: String
				
				/// Yes Fits
				result = prettyString(width: 30, doc: [].fillCat())
				str = ""
				expect(result) == str
				
				result = prettyString(width: 30, doc: ["a"].fillCat())
				str = "a"
				expect(result) == str
				
				result = prettyString(width: 30, doc: ["a", "b"].fillCat())
				str = "ab"
				expect(result) == str
				
				result = prettyString(width: 30, doc: ["a", "b", "c"].fillCat())
				str = "abc"
				expect(result) == str
				
				/// No Fits
				result = prettyString(width: 0, doc: ["a", "b"].fillCat())
				str = "a\nb"
				expect(result) == str
				
				result = prettyString(width: 2, doc: ["a", "b", "c"].fillCat())
				str = "ab\nc"
				expect(result) == str
			}
		}
		
		// hsep
		describe("hsep"){
			it("should produce concatenated document"){
				var result, str: String
				
				result = prettyString(width: 30, doc: [].hsep())
				str = ""
				expect(result) == str
				
				result = prettyString(width: 30, doc: ["a"].hsep())
				str = "a"
				expect(result) == str
				
				result = prettyString(width: 30, doc: ["a", "b"].hsep())
				str = "a b"
				expect(result) == str
				
				result = prettyString(width: 30, doc: ["a", "b", "c"].hsep())
				str = "a b c"
				expect(result) == str
			}
		}
		
		// vsep
		describe("vsep"){
			it("should produce concatenated document"){
				var result, str: String
				
				result = prettyString(width: 30, doc: [].vsep())
				str = ""
				expect(result) == str
				
				result = prettyString(width: 30, doc: ["a"].vsep())
				str = "a"
				expect(result) == str
				
				result = prettyString(width: 30, doc: ["a", "b"].vsep())
				str = "a\nb"
				expect(result) == str
				
				result = prettyString(width: 30, doc: ["a", "b", "c"].vsep())
				str = "a\nb\nc"
				expect(result) == str
				
				
				/// group
				result = prettyString(width: 30){
					let folded: Document = ["a", "b", "c"].vsep()
					return folded.group()
				}
				str = "a b c"
				expect(result) == str
			}
		}
		
		// MARK: sep
		describe("sep"){
			it("should produce concatenated document"){
				var result, str: String
				
				/// Yes Fits
				result = prettyString(width: 30, doc: [].sep())
				str = ""
				expect(result) == str
				
				result = prettyString(width: 30, doc: ["a"].sep())
				str = "a"
				expect(result) == str
				
				result = prettyString(width: 30, doc: ["a", "b"].sep())
				str = "a b"
				expect(result) == str
				
				result = prettyString(width: 30, doc: ["a", "b", "c"].sep())
				str = "a b c"
				expect(result) == str
				
				
				/// No Fits
				result = prettyString(width: 0, doc: ["a", "b"].sep())
				str = "a\nb"
				expect(result) == str
				
				result = prettyString(width: 3, doc: ["a", "b", "c"].sep())
				str = "a\nb\nc"
				expect(result) == str
			}
		}
		
		// MARK: fillSep
		describe("fillSep"){
			it("should produce concatenated document"){
				var result, str: String
				
				/// Yes Fits
				result = prettyString(width: 30, doc: [].fillSep())
				str = ""
				expect(result) == str
				
				result = prettyString(width: 30, doc: ["a"].fillSep())
				str = "a"
				expect(result) == str
				
				result = prettyString(width: 30, doc: ["a", "b"].fillSep())
				str = "a b"
				expect(result) == str
				
				result = prettyString(width: 30, doc: ["a", "b", "c"].fillSep())
				str = "a b c"
				expect(result) == str
				
				
				/// No Fits
				result = prettyString(width: 0, doc: ["a", "b"].fillSep())
				str = "a\nb"
				expect(result) == str
				
				result = prettyString(width: 3, doc: ["a", "b", "c"].fillSep())
				str = "a b\nc"
				expect(result) == str
			}
		}
		
		// MARK: encloseSep
		describe("encloseSep"){
			it("should produce enclosed and separated document"){
				var result, str: String
				
				/// Yes Fits
				result = prettyString(width: 30){
					return [].encloseSep(.comma, open: .lparen, close: .rparen)
				}
				str = "()"
				expect(result) == str
				
				result = prettyString(width: 30){
					return ["a"].encloseSep(.comma, open: .lparen, close: .rparen)
				}
				str = "(a)"
				expect(result) == str
				
				result = prettyString(width: 30){
					return ["a", "b", "c"].encloseSep(.comma, open: .lparen, close: .rparen)
				}
				str = "(a,b,c)"
				expect(result) == str
				
				
				/// No Fits
				result = prettyString(width: 10){
					return "prefix" <+> ["100", "1000", "10000"].encloseSep(.comma, open: .lparen, close: .rparen)
				}
				
				///             | boundary (10)
				///             |
				str = "prefix (100\n"
					+ "       ,1000\n"
					+ "       ,10000)"
				
				expect(result) == str
			}
		}
		
		// MARK: encloseSepNest
		describe("encloseSepNest"){
			it("should produce enlosed and separated and (nested (if necessary)) document"){
				var result, str: String
				
				/// Yes Fits
				result = prettyString(width: 30){
					return [].encloseSepNest(4, sep: .comma, open: .lparen, close: .rparen)
				}
				str = "()"
				expect(result) == str
				
				result = prettyString(width: 30){
					return ["a"].encloseSepNest(4, sep: .comma, open: .lparen, close: .rparen)
				}
				str = "(a)"
				expect(result) == str
				
				result = prettyString(width: 30){
					return ["a", "b", "c"].encloseSepNest(4, sep: .comma, open: .lparen, close: .rparen)
				}
				str = "(a, b, c)"
				expect(result) == str
				
				
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
				
				expect(result) == str
			}
		}
		
		// MARK: prettify
		describe("should produce prettified document"){
			it(""){
				var result, str: String
				var dict: Dictionary<String, String>
				
				/// Yes Fits
				
				dict = [:]
				result = prettyString(width: 30){
					return dict.prettify(4)
				}
				str = "[]"
				expect(result) == str
				
				dict = ["a": "a0"]
				result = prettyString(width: 30){
					return dict.prettify(4)
				}
				str = "[a: a0]"
				expect(result) == str
				
				dict = ["a": "a0", "c": "c0", "b": "b0"]
				result = prettyString(width: 30){
					return dict.prettify(4)
				}
				str = "[a: a0, b: b0, c: c0]"
				expect(result) == str
				
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
				expect(result) == str
			}
		}
		
		// MARK: style
		describe("style"){
			it(""){
				var result, str: String
				let escape = "\u{001B}["
				let suffix = escape + "0m"
				var doc: Document
				
				doc = "a" <+> "b"
				result = doc.intensity(.Bold).prettify(width: 30)
				str = escape + "1m" + "a b" + suffix
				expect(result) == str
				
				doc = ("a" <+> "b").underline(.Single) <> "c"
				result = doc.prettify(width: 30)
				str = escape + "4m" + "a b" + suffix + "c"
				expect(result) == str
			}
		}
	}
}
