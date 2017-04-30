Changelog
=========

v1.2.0 - 2017-03-02
-------------------

- Added `compileHTMLDietFileString`, a variant of `compileHTMLDietString` that can make use of includes and extensions - [issue #24][issue24]
- Fixed a compile error for filter nodes and output ranges that are not `nothrow`
- Fixed extraneous newlines getting inserted in front of HTML text nodes when pretty printing was enabled

[issue24]: https://github.com/rejectedsoftware/diet-ng/issues/24


v1.1.4 - 2017-02-23
-------------------

- Fixes formatting of singluar elements in pretty HTML output - [issue #18][issue18]
- Added support for Boolean attributes that are sourced from a propert/implicit function call (by Sebastian Wilzbach) - [issue #19][issue19], [pull #20][issue20]

[issue18]: https://github.com/rejectedsoftware/diet-ng/issues/18
[issue19]: https://github.com/rejectedsoftware/diet-ng/issues/19
[issue20]: https://github.com/rejectedsoftware/diet-ng/issues/20


v1.1.3 - 2017-02-09
-------------------

### Bug fixes ###

- Works around an internal compiler error on 2.072.2 that got triggered in 1.1.2


v1.1.2 - 2017-02-06
-------------------

### Features and improvements ###

- Class/ID definitions (`.cls#id`) can now be specified in any order - [issue #9][issue9]
- Block definitions can now also be in included files - [issue #14][issue14]
- Multiple contents definitions for the same block are now handled properly - [issue #13][issue13]

[issue9]: https://github.com/rejectedsoftware/diet-ng/issues/9
[issue13]: https://github.com/rejectedsoftware/diet-ng/issues/13
[issue14]: https://github.com/rejectedsoftware/diet-ng/issues/14


v1.1.1 - 2016-12-19
-------------------

### Bug fixes ###

- Fixed parsing of empty lines in raw text blocks


v1.1.0 - 2016-09-29
-------------------

This release adds support for pretty printing and increases backwards
compatibility with older DMD front end versions.

### Features and improvements ###

- Compiles on DMD 2.068.0 up to 2.071.2
- Supports pretty printed HTML output by inserting a `htmlOutputStyle` field
  in a traits struct - [issue #8][issue8]

[issue8]: https://github.com/rejectedsoftware/diet-ng/issues/8


v1.0.0 - 2016-09-22
-------------------

This is the first stable release of diet-ng. Compared to the original
`vibe.templ.diet` module in vibe.d, it offers a large number of
improvements.

### Features and improvements ###

- No external dependencies other than Phobos
- Extensible/configurable with traits structures
- Supports inline and nested tags syntax
- Supports string interpolations within filter nodes (falls back to
  runtime filters)
- Supports arbitrary uses other than generating HTML, for example we
  use it similar to QML/XAML for our internal UI framework
- The API is `@safe` and `nothrow` where possible
- Uses less memory during compilation
- Comprehensive unit test suite used throughout development
- Supports AngularJS special attribute names
