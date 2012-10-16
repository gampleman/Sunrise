Sunrise
=======

`Sunrise` is a Markdown parser based on the original code of the
[Sundown library](http://github.com/vmg/sundown).

For a greater description see [Sundown library](http://github.com/vmg/sundown) page, here I will only talk about features unique to this fork.

Syntax Highlighting
-------------------

Sunrise bundles the Pygments library and automatically highlights source code.

MathML Support
--------------

Sunrise recognizes LaTeX math in `$` character delimeters and transforms it to renderable MathML.

Credits
-------

`Sunrise` is a fork of `Sundown` which is based on the original Upskirt parser by Natacha Porté, with many additions
by Vicent Marti (@vmg) and contributions from the following authors:

	Ben Noordhuis, Bruno Michel, Joseph Koshy, Krzysztof Kowalczyk, Samuel Bronson,
	Shuhei Tanuma



Install
-------

Sunrise supports CocoaPods. Add `pod "Sunrise"` to your Podfile and run `pod install`.
