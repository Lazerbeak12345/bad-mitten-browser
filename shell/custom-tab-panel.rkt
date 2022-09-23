#lang typed/racket/base
#|
File derived directly from

https://github.com/racket/typed-racket/blob/master/typed-racket-test/gui/succeed/test-tab-augments.rkt

I was the original author of that file, but it should be noted that this file,
and the one I derived it from, are both under a seperate license than the rest
of the code in this project.

See the https://github.com/racket/typed-racket/blob/master/LICENSE file for
information on how this file is licenced. I'm prefering the MIT licence for
this code:

Copyright Lazerbeak12345 2022

> Permission is hereby granted, free of charge, to any
> person obtaining a copy of this software and associated
> documentation files (the "Software"), to deal in the
> Software without restriction, including without
> limitation the rights to use, copy, modify, merge,
> publish, distribute, sublicense, and/or sell copies of
> the Software, and to permit persons to whom the Software
> is furnished to do so, subject to the following
> conditions:
>
> The above copyright notice and this permission notice
> shall be included in all copies or substantial portions
> of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF
> ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
> TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
> PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT
> SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
> CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
> OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
> IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
> DEALINGS IN THE SOFTWARE.
|#
(require (only-in typed/racket/class class super-new init-field define/augment define/override super)
         (only-in typed/racket/gui/base tab-panel% Tab-Panel%))
(define-type
 Tab-Panel-Closable%
 (Class #:implements/inits Tab-Panel%
        (init-field [on-reorder-callback ((Listof Exact-Nonnegative-Integer) -> Void) #:optional]
                    [on-close-request-callback (Exact-Nonnegative-Integer -> Void) #:optional])))
(define tab-panel-closable%
  :
  Tab-Panel-Closable%
  (class tab-panel%
    (super-new)
    (init-field [on-reorder-callback (lambda (_) (void))]
                [on-close-request-callback (lambda (_) (void))])
    (define/augment (on-reorder tab-list) (on-reorder-callback tab-list))
    (define/override (on-close-request index)
      (super on-close-request index)
      (on-close-request-callback index))))
(provide tab-panel-closable%
         Tab-Panel-Closable%)
