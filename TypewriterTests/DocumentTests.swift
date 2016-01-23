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

}