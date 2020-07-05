# Bad-Mitten browser

A browser using the racket framework to be as small as possible.

## Target platform(s)

I plan on focusing all of my development on Linux. I don't see any reason why I
woudn't support other \*nixes, such as Darwin (macos), BSDs, Minix, 
Redox, and the like, so patches to make it work there will be likely to be
given some degree of priority over feature functionality.

However, Windows compatibility is a low priority. It's nice if it works on
Windows, but I don't want to spend very much effort on it, as I hold the beleif
that the Windows NT architecture is obsolete, and I don't plan on giving
obsolete platforms any sort of priority.
**As of yet, I have seen nothing to inicate that it _wouldn't_ work on Windows,
but Windows users should not expect to be able to run development versions, for
reasons mentioned above.**

## Contributing

To contribute, fork the project, make a branch, make your changes, then Pull
request that branch into this project's master branch, or other branch on this
project, if that would be better. (EX: what if we make a branch dedecated to
finding ways to streamline the CSS engine, and you've got an idea? Well, that's
where you would both pull from, and send a PR to.)

## Details about GUI

Right now, the GUI (not the rendering engine) is basically done untill they
make changes to improove what tabs can do (and what the top bar can do).
I would like the tabs to have these changes:

- They need to try to be as wide as possible, but once they are too small, hide
  like it does already.
- They need (x) buttons to close them.

I would like the titlebar to have these changes:

- It should have these widgets, in order:
  -  Add Tab
  -  Back
  -  Forward
  -  Reload
  -  The URL bar

And all of these buttons should have icons instead of text. Show the text when
hovering.

### Style Guide

I come from the world of JavaScript and other C-based languages. Thus, I have
one change different from the standard adopted by most of the Racket community:

> When adding a close paren (as in `)` `]` or `}`), unless its corresponding
> opener is on the same line, give this paren its own line.

This brings two benifits:

1. **Enchanced readability.** It's clearer when a code-block ends, and readers
   of the code don't have to assume that the whitespace formatting correctly
   matches the parenthasis depth.
2. **Better version control.** While tools such as Git work regardless of how
   we format our file, tools such as Git count any line touched as modified. 
   If one modifies a line, there is a chance that they introduce unintended
   behavior in said line. This means less risk.

### Example

```racket
#lang racket
(define (do-something argumentName)
   (print (if (string? argumentName)
              argumentName
              "something"
              )
          )
   )
```

## Tools used

1. `html-parsing`. It's _really_ good at parsing html5 code. 
   It provides `html->xexp`. (yes, it even handles script tags right. The 
   script is just a string!)
2. `net/url`, `net/url-connect` and, `net/head`. Tools for managing connections
   to servers.

