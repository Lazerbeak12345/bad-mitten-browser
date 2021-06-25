# Bad-Mitten browser

A www browser using the racket framework to be as small as possible.

Now a year old! :tada:

> This software is free software under the GPLv3 or later, and respects not
> only the four freedoms, but also your privacy, unlike other browsers I
> shouldn't name.
> 
> 0. The freedom to run the program as you wish, for any purpose (freedom 0).
> 1. The freedom to study how the program works, and change it so it does your
>    computing as you wish (freedom 1). Access to the source code is a
>    precondition for this.
> 2. The freedom to redistribute copies so you can help your neighbor (freedom
>    2).
> 3. The freedom to distribute copies of your modified versions to others
>    (freedom 3). By doing this you can give the whole community a chance to
>    benefit from your changes. Access to the source code is a precondition for
>    this.

[![GPLv3 or higher logo][gpl-logo]][gpl-link]

[gpl-logo]: https://www.gnu.org/graphics/gplv3-with-text-136x68.png
[gpl-link]: https://www.gnu.org/licenses/gpl-3.0.txt


## Target platform(s)

I plan on focusing all of my development on Linux. I don't see any reason why I
wouldn't support other \*nixes, such as Darwin (macOS), BSDs, Minix, Redox, and
the like, so patches to make it work there will be likely to be given some
degree of priority over feature functionality.

However, Windows compatibility is a low priority. It's nice if it works on
Windows, but I don't want to spend very much effort on it, I don't plan on
giving that platform any sort of priority. **As of yet, I have seen nothing to
indicate that it _wouldn't_ work on Windows, but Windows users should not expect
to be able to run development versions, for reasons mentioned above.**

## Contributing

To contribute, fork the project, make a branch, make your changes, then Pull
request that branch into this project's master branch, or other branch on this
project, if that would be better. (EX: what if we make a branch dedicated to
finding ways to streamline the CSS engine, and you've got an idea? Well, that's
where you would both pull from, and send a PR to.)

## Details about GUI

Right now, the GUI (not the rendering engine) is basically done until they make
changes to improve what tabs can do (and what the top bar can do).

### GUI things I can't do yet, but want to, once racket/gui gets better

I would like the tabs to have these changes:

- They need to try to be as wide as possible, but once they are too small, hide
  like it does already.
- They need (x) buttons to close them.

I would like the titlebar to have these changes:

- It should have these widgets, in order:
  - Add Tab
  - Back and Forward joined (A "split-button" sort of thing)
  - Reload
  - The URL bar
- I might want to make the additive actions on the right if the window action
  buttons are on the left (default macOS behavior).

And all of these buttons should have icons instead of text. Show the text when
hovering. (System icons would be best here)

### Style Guide

For a time I was abiding by this simple variant from the racket style guide:

> When adding a close paren (as in `)` `]` or `}`), unless its corresponding
> opener is on the same line, give this paren its own line.

However, I have since reversed that decision. The benefits were very little
when using an editor with parenthesis highlighting support.

All imports must use `only-in` to improove code readability.

## Tools used

1. `racket` and `typed/racket` Yes, I must give due credit there. They're
   pretty darn awesome.
2. `html-parsing`. It's _really_ good at parsing html5 code.
   It provides `html->xexp`. (yes, it even handles script tags right. The
   script is just a string!)
3. `net/url`, `net/url-connect` and, `net/head`. Tools for managing connections
   to servers.
