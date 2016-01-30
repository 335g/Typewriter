# Typewriter

[![Platform support](https://img.shields.io/badge/platform-iOS%20%7C%20OS%20X-lightgrey.svg?style=flat-square)](https://github.com/ReSwift/ReSwift/blob/master/LICENSE.md)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat-square)](https://github.com/Carthage/Carthage)
[![License MIT](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](LICENSE)

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

  `Document.string` is used when you don't need auto linebreak. `"\n"` is changed to linebreak. `Document` confirm to `StringLiteralConvertible`.

  ```swift
  let document = Document.string("abc")

  ///
  /// equal to
  ///   let document: Document = "abc"
  ```

- **Document.texts**

  `Document.texts` is used when you need auto linebreak. Position sandwiching the linebreak is determined by `prettify/prettyString`'s arugments `rule: RenderingRule` & `width: Int`.

  ```swift
  let doc = Document
    .texts("This is a sample to use Typewriter.")
    .fillSep()
    .hang(2)

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
  /// + "  sample to use\n"
  /// + "  Typewriter."
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
