# Typewriter

[![Platform support](https://img.shields.io/badge/platform-iOS%20%7C%20OS%20X-lightgrey.svg?style=flat-square)](https://github.com/ReSwift/ReSwift/blob/master/LICENSE.md)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat-square)](https://github.com/Carthage/Carthage)
[![License MIT](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](LICENSE)
[![Join the chat at https://gitter.im/335g/Typewriter](https://img.shields.io/badge/GITTER-join%20chat-green.svg?style=flat-square)](https://gitter.im/335g/Typewriter?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

`Typewriter` is a Swift μframework for pretty printing.

## Use

You can get rendering pretty `String` to use `prettify/prettyString` in `Typewriter`.

```swift
let doc = Document
	.texts("This is a sample to use Typewriter.")
	.fillSep()
	.hang(2)

var result: String
result = doc.prettify()

///
/// Trailing closure by `prettyString`
///
result = prettyString(width: 15){
    return Document
        .texts("This is a sample to use Typewriter.")
        .fillSep()
        .hang(2)
}
```

- **Document.string**

  `Document.string` is used when you don't want a new line in the middle of a sentence. `Document` conform to `StringLiteralConvertible`.


  ```swift
  let document = Document
      .string("This is a sample to use Typewriter.")

  ///
  /// equal to
  ///   let document: Document = "This is a sample to use Typewriter."
  ```

- **Document.texts**

  `Document.texts` is used when you want a newline in the middle of a sentence in an appropriate manner. Position sandwiching the linebreak is determined by `prettify/prettyString`'s arugments `rule: RenderingRule` & `width: Int`.

  ```swift
  let doc = Document
    .texts("This is a sample to use Typewriter.")
    .fillSep()

  var result: String

  /// (1) width: 60 (default)
  result = doc.prettify()
  /// "This is a sample to use Typewriter."

  /// (2) width: 30
  result = doc.prettify(width: 30)
  ///                                  | boundary (30)
  ///                                  |
  ///   "This is a sample to use\n"
  /// + "Typewriter."

  /// (3) width: 15
  result = doc.prettify(width: 15)
  ///                  | boundary (15)
  ///                  |
  ///   "This is a\n"
  /// + "sample to use\n"
  /// + "Typewriter."
  ```

- **Operators**

  `Document` is combined by operators.

  ```swift
  let a: Document = "a" <> "b"   // "ab"
  let b: Document = "a" <+> "b"  // "a b"
  let c: Document = "a" </-> "b" // "a\nb"
  ```

## License

The MIT License (MIT)

Copyright (c) 2016 Yoshiki Kudo

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
