//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

import XCTest
import Assertions
import Prelude
@testable import Typewriter

final class DocumentTests: XCTestCase {
	
	// MARK: - Constructor
	
	func testDocumentEmptyProduceEmpty(){
		let a: Document = .empty
		let b: Document = .Empty
		assertEqual(a, b)
	}
	
	func testDocumentCharProduceChar(){
		let a: Document = .char("a")
		let b: Document = .Char("a")
		assertEqual(a, b)
	}
	
	func testDocumentCharProduceLineIfInputLinebreak(){
		let a: Document = .char("\n")
		let b: Document = .Line
		assertEqual(a, b)
	}
	
	func testDocumentTextProduceText(){
		if let a: Document = try? .text("a") {
			let b: Document = .Text("a")
			assertEqual(a, b)
		}else {
			failure(".text(`A`) is equal to `.TextA`")
		}
	}
	
	func testDocumentStringProduceTextDevidedLinebreak(){
		let a: Document = .string("This is a test \nfor string constructor.")
		let b: Document = .Text("This is a test ") </+> .Text("for string constructor.")
		assertEqual(a, b)
	}
	
	func testDocumentStringLiteralInitializerProduceString(){
		let a: Document = "a"
		let b: Document = .string("a")
		assertEqual(a, b)
	}
	
	// MARK: - operator
	
	func testDocumentOperator1ProduceDocument(){
		let a: Document = .char("a") <> .char("b")
		let b: Document = .Cat(.Char("a"), .Char("b"))
		assertEqual(a, b)
	}
	
	func testDocumentOperator2ProduceDocument(){
		let a: Document = .char("a") <+> .char("b")
		let b: Document = .Cat(
			.Char("a"),
			.Cat(.space, .Char("b"))
		)
		assertEqual(a, b)
	}
	
	func testDocumentOperator3ProduceDocument(){
		let a: Document = .char("a") </+> .char("b")
		let b: Document = .Cat(
			.Char("a"),
			.Cat(.line, .Char("b"))
		)
		assertEqual(a, b)
	}
	
	func testDocumentOperator4ProduceDocument(){
		let a: Document = .char("a") </-> .char("b")
		let b: Document = .Cat(
			.Char("a"),
			.Cat(.linebreak, .Char("b"))
		)
		assertEqual(a, b)
	}
	
	func testDocumentOperator5ProduceDocument(){
		let a: Document = .char("a") <+/+> .char("b")
		let b: Document = .Cat(
			.Char("a"),
			.Cat(.softline, .Char("b"))
		)
		assertEqual(a, b)
	}
	
	func testDocumentOperator6ProduceDocument(){
		let a: Document = .char("a") <-/-> .char("b")
		let b: Document = .Cat(
			.Char("a"),
			.Cat(.softbreak, .Char("b"))
		)
		assertEqual(a, b)
	}

	// MARK: - extension Array where Element: DocumentType
	
	// MARK: hcat
	func testDocumentArrayHcatProduceFoldedDocument(){
		let empty: Document = .empty
		let a: Document = .char("a")
		let b: Document = .char("b")
		let c: Document = .char("c")
		
		let a0: Document = [].hcat()
		assertEqual(a0, empty)
		
		let b1: Document = [a].hcat()
		let b2: Document = a
		assertEqual(b1, b2)
		
		let c1: Document = [a, b].hcat()
		let c2: Document = a <> b
		let c3: Document = a.beside(b)
		assertEqual(c1, c2)
		assertEqual(c1, c3)
		
		let d1: Document = [a, b, c].hcat()
		let d2: Document = a <> b <> c
		let d3: Document = a.beside(b.beside(c))
		assertEqual(d1, d2)
		assertEqual(d1, d3)
	}
	
	// MARK: vcat
	func testDocumentArrayVcatProduceFoldedDocument(){
		let empty: Document = .empty
		let a: Document = .char("a")
		let b: Document = .char("b")
		let c: Document = .char("c")
		
		let a0: Document = [].vcat()
		assertEqual(a0, empty)
		
		let b1: Document = [a].vcat()
		let b2: Document = a
		assertEqual(b1, b2)
		
		let c1: Document = [a, b].vcat()
		let c2: Document = a </-> b
		let c3: Document = a.beside(
			Document.FlatAlt(.hardline, empty).beside(b)
		)
		assertEqual(c1, c2)
		assertEqual(c1, c3)
		
		let d1: Document = [a, b, c].vcat()
		let d2: Document = a </-> b </-> c
		let d3: Document = a.beside(
			Document.FlatAlt(.hardline, empty).beside(
				b.beside(
					Document.FlatAlt(.hardline, empty).beside(c)
				)
			)
		)
		assertEqual(d1, d2)
		assertEqual(d1, d3)
	}
	
	// MARK: cat
	func testDocumentArrayCatProduceFoldedDocument(){
		let empty: Document = .empty
		let a: Document = .char("a")
		let b: Document = .char("b")
		
		let a1: Document = [].cat()
		let a2: Document = .Union(empty.flatten(), empty)
		assertEqual(a1, a2)
		
		let b1: Document = [a].cat()
		let b2: Document = [a].vcat()
		let b3: Document = .Union(b2.flatten(), b2)
		assertEqual(b1, b3)
		
		let c1: Document = [a, b].cat()
		let c2: Document = [a, b].vcat()
		let c3: Document = .Union(c2.flatten(), c2)
		assertEqual(c1, c3)
	}
	
	// MARK: fillCat
	func testDocumentArrayFillCatProduceFoldedDocument(){
		let empty: Document = .empty
		let a: Document = .char("a")
		let b: Document = .char("b")
		let c: Document = .char("c")
		let linebreak: Document = .linebreak
		
		let a1: Document = [].fillCat()
		assertEqual(a1, empty)
		
		let b1: Document = [a].fillCat()
		let b2: Document = a
		assertEqual(b1, b2)
		
		let c1: Document = [a, b].fillCat()
		let c2: Document = a <-/-> b
		let c3: Document = a.beside(
			Document.Union(linebreak.flatten(), linebreak).beside(b)
		)
		assertEqual(c1, c2)
		assertEqual(c1, c3)
		
		let d1: Document = [a, b, c].fillCat()
		let d2: Document = a <-/-> b <-/-> c
		let d3: Document = a.beside(
			Document.Union(linebreak.flatten(), linebreak).beside(
				b.beside(
					Document.Union(linebreak.flatten(), linebreak).beside(c)
				)
			)
		)
		assertEqual(d1, d2)
		assertEqual(d1, d3)
	}
	
	// MARK: hsep
	func testDocumentArrayHsepProduceFoldedDocument(){
		let empty: Document = .empty
		let a: Document = .char("a")
		let b: Document = .char("b")
		let c: Document = .char("c")
		
		let a1: Document = [].hsep()
		assertEqual(a1, empty)
		
		let b1: Document = [a].hsep()
		let b2: Document = a
		assertEqual(b1, b2)
		
		let c1: Document = [a, b].hsep()
		let c2: Document = a <+> b
		let c3: Document = a.beside(
			Document.space.beside(b)
		)
		assertEqual(c1, c2)
		assertEqual(c1, c3)
		
		let d1: Document = [a, b, c].hsep()
		let d2: Document = a <+> b <+> c
		let d3: Document = a.beside(
			Document.space.beside(
				b.beside(
					Document.space.beside(c)
				)
			)
		)
		assertEqual(d1, d2)
		assertEqual(d1, d3)
	}
	
	// MARK: vsep
	func testDocumentArrayVsepProduceFoldedDocument(){
		let empty: Document = .empty
		let a: Document = .char("a")
		let b: Document = .char("b")
		let c: Document = .char("c")
		
		let a1: Document = [].vsep()
		assertEqual(a1, empty)
		
		let b1: Document = [a].vsep()
		let b2: Document = a
		assertEqual(b1, b2)
		
		let c1: Document = [a, b].vsep()
		let c2: Document = a </+> b
		let c3: Document = a.beside(
			Document.FlatAlt(.hardline, .space).beside(b)
		)
		assertEqual(c1, c2)
		assertEqual(c1, c3)
		
		let d1: Document = [a, b, c].vsep()
		let d2: Document = a </+> b </+> c
		let d3: Document = a.beside(
			Document.FlatAlt(.hardline, .space).beside(
				b.beside(
					Document.FlatAlt(.hardline, .space).beside(c)
				)
			)
		)
		assertEqual(d1, d2)
		assertEqual(d1, d3)
	}
	
	// MARK: sep
	func testDocumentArraySepProduceFoldedDocument(){
		let empty: Document = .empty
		let a: Document = .char("a")
		let b: Document = .char("b")
		
		let a1: Document = [].sep()
		let a2: Document = .Union(empty.flatten(), empty)
		assertEqual(a1, a2)
		
		let b1: Document = [a].sep()
		let b2: Document = [a].vsep()
		let b3: Document = .Union(b2.flatten(), b2)
		assertEqual(b1, b3)
		
		let c1: Document = [a, b].sep()
		let c2: Document = [a, b].vsep()
		let c3: Document = .Union(c2.flatten(), c2)
		assertEqual(c1, c3)
	}
	
	// MARK: fillSep
	func testDocumentArrayFillSepProduceFoldedDocument(){
		let empty: Document = .empty
		let a: Document = .char("a")
		let b: Document = .char("b")
		let c: Document = .char("c")
		let line: Document = .line
		
		let a1: Document = [].fillSep()
		assertEqual(a1, empty)
		
		let b1: Document = [a].fillSep()
		let b2: Document = a
		assertEqual(b1, b2)
		
		let c1: Document = [a, b].fillSep()
		let c2: Document = a <+/+> b
		let c3: Document = a.beside(
			Document.Union(line.flatten(), line).beside(b)
		)
		assertEqual(c1, c2)
		assertEqual(c1, c3)
		
		let d1: Document = [a, b, c].fillSep()
		let d2: Document = a <+/+> b <+/+> c
		let d3: Document = a.beside(
			Document.Union(line.flatten(), line).beside(
				b.beside(
					Document.Union(line.flatten(), line).beside(c)
				)
			)
		)
		assertEqual(d1, d2)
		assertEqual(d1, d3)
	}
}