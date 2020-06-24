# Bad-Mitten browser

A browser using the racket framework to be as small as possible.

## Contributing

This is still very much at the design phase.

Right now there's a bunch of files
for parsing html5, but according to the docs on the library `html`, an html4
parsing library, the library `html-parsing` might be the best possible option.

## Tools used

1. html-parsing. It's _really_ good at parsing html5 code. It provides `html->xexp`. (yes, it even handles script tags right. The script is just a string!)
