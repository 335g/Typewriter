//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

import Quick
import Nimble
import XCTest
@testable import Typewriter

final class DocumentSpec: QuickSpec {
	override func spec() {
		
		// MARK: - Constructor
		
		describe("empty"){
			it("should produce .Empty"){
				let a: Document = .empty
				let b: Document = .emptyDoc
				
				expect(a) == b
			}
		}
		
		describe("char"){
			it("should produce .Char"){
				let a: Document = .char("a")
				let b: Document = .charDoc("a")
				
				expect(a) == b
			}
			
			it("should produce .Line with `\n`"){
				let a: Document = .char("\n")
				let b: Document = .lineDoc
				
				expect(a) == b
			}
		}
		
		describe("text"){
			it("should produce .Text"){
				if let a = try? Document.textDoc("a") {
					let b: Document = .textDoc("a")
					
					expect(a) == b
					
				}else {
					XCTFail(".text(\"a\") should be .Text(\"a\")")
				}
			}
		}
		
		describe("string"){
			it("should produce .Text(s)"){
				let a: Document = .string("This is a test \nfor string constructor.")
				let b: Document = .textDoc("This is a test ") </+> .textDoc("for string constructor.")
				
				expect(a) == b
			}
		}
		
		describe("StringLiteral"){
			it("should produce document equal to .string"){
				let a: Document = "a"
				let b: Document = .string("a")
				
				expect(a) == b
			}
		}
		
		// MARK: - Operator
		
		describe("<>"){
			it("should produce .Cat"){
				let a: Document = .char("a") <> .char("b")
				let b: Document = .catDoc(.charDoc("a"), .charDoc("b"))
				
				expect(a) == b
			}
		}
		
		describe("<+>"){
			it("should produce .Cat"){
				let a: Document = .char("a") <+> .char("b")
				let b: Document = .catDoc(
					.charDoc("a"),
					.catDoc(.space, .charDoc("b"))
				)
				
				expect(a) == b
			}
		}
		
		describe("</+>"){
			it("should produce .Cat"){
				let a: Document = .char("a") </+> .char("b")
				let b: Document = .catDoc(
					.charDoc("a"),
					.catDoc(.line, .charDoc("b"))
				)
				
				expect(a) == b
			}
		}
		
		describe("</->"){
			it("should produce .Cat"){
				let a: Document = .char("a") </-> .char("b")
				let b: Document = .catDoc(
					.charDoc("a"),
					.catDoc(.linebreak, .charDoc("b"))
				)
				
				expect(a) == b
			}
		}
		
		describe("<+/+>"){
			it("should produce .Cat"){
				let a: Document = .char("a") <+/+> .char("b")
				let b: Document = .catDoc(
					.charDoc("a"),
					.catDoc(.softline, .charDoc("b"))
				)
				
				expect(a) == b
			}
		}
		
		describe("<-/->"){
			it("should produce .Cat"){
				let a: Document = .char("a") <-/-> .char("b")
				let b: Document = .catDoc(
					.charDoc("a"),
					.catDoc(.softbreak, .charDoc("b"))
				)
				
				expect(a) == b
			}
		}
		
		// MARK: - extension Array where Element: DocumentType
		
		describe("hcat"){
			it("should produce concatenated document"){
				let empty: Document = .empty
				let a: Document = .char("a")
				let b: Document = .char("b")
				let c: Document = .char("c")
				
				let a0: Document = [].hcat()
				expect(a0) == empty
				
				let b1: Document = [a].hcat()
				let b2: Document = a
				expect(b1) == b2
				
				let c1: Document = [a, b].hcat()
				let c2: Document = a <> b
				let c3: Document = a.beside(b)
				expect(c1) == c2
				expect(c1) == c3
				
				let d1: Document = [a, b, c].hcat()
				let d2: Document = a <> b <> c
				let d3: Document = a.beside(b.beside(c))
				expect(d1) == d2
				expect(d1) == d3
			}
		}
		
		describe("vcat"){
			it("should produce concatenated document"){
				let empty: Document = .empty
				let a: Document = .char("a")
				let b: Document = .char("b")
				let c: Document = .char("c")
				
				let a0: Document = [].vcat()
				expect(a0) == empty
				
				let b1: Document = [a].vcat()
				let b2: Document = a
				expect(b1) == b2
				
				let c1: Document = [a, b].vcat()
				let c2: Document = a </-> b
				let c3: Document = a.beside(
					Document.flatAltDoc(.hardline, empty).beside(b)
				)
				expect(c1) == c2
				expect(c1) == c3
				
				let d1: Document = [a, b, c].vcat()
				let d2: Document = a </-> b </-> c
				let d3: Document = a.beside(
					Document.flatAltDoc(.hardline, empty).beside(
						b.beside(
							Document.flatAltDoc(.hardline, empty).beside(c)
						)
					)
				)
				expect(d1) == d2
				expect(d1) == d3
			}
		}
		
		describe("cat"){
			it("should produce concatenated document"){
				let empty: Document = .empty
				let a: Document = .char("a")
				let b: Document = .char("b")
				
				let a1: Document = [].cat()
				let a2: Document = .unionDoc(empty.flatten(), empty)
				expect(a1) == a2
				
				let b1: Document = [a].cat()
				let b2: Document = [a].vcat()
				let b3: Document = .unionDoc(b2.flatten(), b2)
				expect(b1) == b3
				
				let c1: Document = [a, b].cat()
				let c2: Document = [a, b].vcat()
				let c3: Document = .unionDoc(c2.flatten(), c2)
				expect(c1) == c3
			}
		}
		
		describe("fillCat"){
			it("should produce concatenated document"){
				let empty: Document = .empty
				let a: Document = .char("a")
				let b: Document = .char("b")
				let c: Document = .char("c")
				let linebreak: Document = .linebreak
				
				let a1: Document = [].fillCat()
				expect(a1) == empty
				
				let b1: Document = [a].fillCat()
				let b2: Document = a
				expect(b1) == b2
				
				let c1: Document = [a, b].fillCat()
				let c2: Document = a <-/-> b
				let c3: Document = a.beside(
					Document.unionDoc(linebreak.flatten(), linebreak).beside(b)
				)
				expect(c1) == c2
				expect(c1) == c3
				
				let d1: Document = [a, b, c].fillCat()
				let d2: Document = a <-/-> b <-/-> c
				let d3: Document = a.beside(
					Document.unionDoc(linebreak.flatten(), linebreak).beside(
						b.beside(
							Document.unionDoc(linebreak.flatten(), linebreak).beside(c)
						)
					)
				)
				expect(d1) == d2
				expect(d1) == d3
			}
		}
		
		describe("hsep"){
			it("should produce concatenated document"){
				let empty: Document = .empty
				let a: Document = .char("a")
				let b: Document = .char("b")
				let c: Document = .char("c")
				
				let a1: Document = [].hsep()
				expect(a1) == empty
				
				let b1: Document = [a].hsep()
				let b2: Document = a
				expect(b1) == b2
				
				let c1: Document = [a, b].hsep()
				let c2: Document = a <+> b
				let c3: Document = a.beside(
					Document.space.beside(b)
				)
				expect(c1) == c2
				expect(c1) == c3
				
				let d1: Document = [a, b, c].hsep()
				let d2: Document = a <+> b <+> c
				let d3: Document = a.beside(
					Document.space.beside(
						b.beside(
							Document.space.beside(c)
						)
					)
				)
				expect(d1) == d2
				expect(d1) == d3
			}
		}
		
		describe("vsep"){
			it("should produce concatenated document"){
				let empty: Document = .empty
				let a: Document = .char("a")
				let b: Document = .char("b")
				let c: Document = .char("c")
				
				let a1: Document = [].vsep()
				expect(a1) == empty
				
				let b1: Document = [a].vsep()
				let b2: Document = a
				expect(b1) == b2
				
				let c1: Document = [a, b].vsep()
				let c2: Document = a </+> b
				let c3: Document = a.beside(
					Document.flatAltDoc(.hardline, .space).beside(b)
				)
				expect(c1) == c2
				expect(c1) == c3
				
				let d1: Document = [a, b, c].vsep()
				let d2: Document = a </+> b </+> c
				let d3: Document = a.beside(
					Document.flatAltDoc(.hardline, .space).beside(
						b.beside(
							Document.flatAltDoc(.hardline, .space).beside(c)
						)
					)
				)
				expect(d1) == d2
				expect(d1) == d3
			}
		}
		
		describe("sep"){
			it("should produce concatenated document"){
				let empty: Document = .empty
				let a: Document = .char("a")
				let b: Document = .char("b")
				
				let a1: Document = [].sep()
				let a2: Document = .unionDoc(empty.flatten(), empty)
				expect(a1) == a2
				
				let b1: Document = [a].sep()
				let b2: Document = [a].vsep()
				let b3: Document = .unionDoc(b2.flatten(), b2)
				expect(b1) == b3
				
				let c1: Document = [a, b].sep()
				let c2: Document = [a, b].vsep()
				let c3: Document = .unionDoc(c2.flatten(), c2)
				expect(c1) == c3
			}
		}
		
		describe("fillSep"){
			it("should produce concatenated document"){
				let empty: Document = .empty
				let a: Document = .char("a")
				let b: Document = .char("b")
				let c: Document = .char("c")
				let line: Document = .line
				
				let a1: Document = [].fillSep()
				expect(a1) == empty
				
				let b1: Document = [a].fillSep()
				let b2: Document = a
				expect(b1) == b2
				
				let c1: Document = [a, b].fillSep()
				let c2: Document = a <+/+> b
				let c3: Document = a.beside(
					Document.unionDoc(line.flatten(), line).beside(b)
				)
				expect(c1) == c2
				expect(c1) == c3
				
				let d1: Document = [a, b, c].fillSep()
				let d2: Document = a <+/+> b <+/+> c
				let d3: Document = a.beside(
					Document.unionDoc(line.flatten(), line).beside(
						b.beside(
							Document.unionDoc(line.flatten(), line).beside(c)
						)
					)
				)
				expect(d1) == d2
				expect(d1) == d3
			}
		}
	}
}
