Diet-NG
=======

Diet is a generic compile-time template system based on an XML-like structure. The syntax is heavily influenced by [pug](https://pugjs.org/) (formerly "Jade") and outputting dynamic HTML is the primary goal. It supports pluggable transformation modules, as well as output modules, so that many other uses are possible.

See the preliminary [Specification](SPEC.md) for a syntax overview.

This repository contains the designated successor implementation of the [`vibe.templ.diet` module](https://vibed.org/api/vibe.templ.diet/) of [vibe.d](https://vibed.org/). The current state is almost stable and feature complete and ready for pre-production testing.

[![DUB link](https://img.shields.io/dub/v/diet-ng.svg)](https://code.dlang.org/packages/diet-ng)
[![Build Status](https://travis-ci.org/rejectedsoftware/diet-ng.svg?branch=master)](https://travis-ci.org/rejectedsoftware/diet-ng)


Example
-------

	doctype html
	- auto title = "Hello, <World>";
	html
		head
			title #{title} - example page
		body
			h1= title
			h2 Index
			ol.pageindex
				- foreach (i; 0 .. 3)
					li: a(href="##{i}") Point #{i}
			- foreach (i; 0 .. 3)
				h2(id=i) Point #{i}
				p.
					These are the #[em contents] of point #{i}. Multiple
					lines of text are contained in this paragraph.

Generated HTML output:

	<!DOCTYPE html>
	<html>
		<head>
			<title>Hello, &lt;World&gt; - example page</title>
		</head>
		<body>
			<h1>Hello, &lt;World&gt;</h1>
			<h2>Index</h2>
			<ol class="pageindex">
				<li><a href="#0">Point 0</a></li>
				<li><a href="#1">Point 1</a></li>
				<li><a href="#2">Point 2</a></li>
			</ol>
			<h2 id="0">Point 0</h2>
			<p>These are the <em>contents</em> of point 0. Multiple
			lines of text are contained in this paragraph.</p>
			<h2 id="1">Point 1</h2>
			<p>These are the <em>contents</em> of point 1. Multiple
			lines of text are contained in this paragraph.</p>
			<h2 id="2">Point 2</h2>
			<p>These are the <em>contents</em> of point 2. Multiple
			lines of text are contained in this paragraph.</p>
		</body>
	</html>


Implementation goals
--------------------

- Be as fast as possible. This means moving as many operations from run time to
  compile time as possible.
- Avoid any dynamic memory allocations (unless it happens in user code)
- Let the generated code be fully `@safe` (unless embedded user code isn't)
- Be customizable (filters, translation, DOM transformations, output
  generators), without resorting to global library state
- Operate on ranges. HTML output is written to an output range, input ranges
  are supported within string interpolations and filters/translation support
  is supposed to be implementable using ranges (the latter part is not yet
  implemented).


Experimental HTML template caching
----------------------------------

Since compiling complex Diet templates can slow down the overall compilation
process, the library provides an option to cache and re-use results. It is
enabled by defining the version constant `DietUseCache` (
`"versions": ["DietUseCache"]` in dub.json or `versions "DietUseCache"` in
dub.sdl). It is not recommended to use this feature outside of the usual
edit-compile-run development cycle, especially not for release builds.

Once enabled, the template compiler will look for `_cached_*.d` files in the
"views/" folder, where the `*` consists of the file name of the Diet template
and a unique hash value that identifies the contents of the template, as well
as included/extended ones. If found, it will simply use the contents of that
file instead of going through the whole compilation process.

At runtime, during initialization, the program will then output the contents of
all newly compiled templates to the "views/" folder. For that reason it is
currently **important that the program is run with the current working directory
set to the package directory!** A drawback of this method is that outdated
cached templates will not be deleted automatically. It is necessary to clear all
`_cached_*` files by hand from time to time.

*Note that hopefully this feature will be obsoleted soon by the [work of Stefan
Koch on DMD's CTFE engine](https://github.com/UplinkCoder/dmd/commits/newCTFE).*
