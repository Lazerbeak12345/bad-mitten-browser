# Bad-Mitten browser

A browser using the racket framework to be as small as possible.

## Contributing

This is still very much at the design phase.

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
we format our file, tools such as Git count any line touched as modified. If
one modifies a line, there is a chance that they introduce unintended behavior
in said line. This means less risk.

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

1. html-parsing. It's _really_ good at parsing html5 code. It provides `html->xexp`. (yes, it even handles script tags right. The script is just a string!)
