#lang typed/racket/base
#|
This file is a part of the Bad-Mitten Browser and is in charge of the xexp type
Copyright (C) 2022  Nathan Fritzler jointly with the Free Software Foundation

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
|#
(define-type Xexp-decl (Pair '*DECL* (Listof (U String Symbol))))
(define-predicate xexp-decl? Xexp-decl)
(provide xexp-decl?
         Xexp-decl)

(define-type Xexp-short (List '& (U String Symbol)))
(define-predicate xexp-short? Xexp-short)
(provide xexp-short?
         Xexp-short)

(define-type Xexp-attr (U (List Symbol) (List Symbol String)))
(define-predicate xexp-attr? Xexp-attr)
(provide xexp-attr?
         Xexp-attr)

(define-type Xexp-attrs (Pair '@ (Listof Xexp-attr)))
(define-predicate xexp-attrs? Xexp-attrs)
(provide xexp-attrs?
         Xexp-attrs)

(define-type Xexp-with-attrs (Pair Symbol (Pair Xexp-attrs (Listof Xexp))))
(define-predicate xexp-with-attrs? Xexp-with-attrs)
(provide xexp-with-attrs?
         Xexp-with-attrs)

(define-type Xexp-no-attrs (Pair Symbol (Listof Xexp)))
(define-predicate xexp-no-attrs? Xexp-no-attrs)
(provide xexp-no-attrs?
         Xexp-no-attrs)

(define-type Xexp (U String Xexp-decl Xexp-short Xexp-with-attrs Xexp-no-attrs))
(define-predicate xexp? Xexp)
(provide xexp?
         Xexp)

(provide xexp-name
         xexp-attrs
         xexp-children
         xexp-short->char)

; First arg is any Xexp that is not a string
(: xexp-name : (U Xexp-decl Xexp-short Xexp-with-attrs Xexp-no-attrs) -> Symbol)
(define (xexp-name theXexp)
  (car theXexp))

(: xexp-attrs : Xexp -> (Listof Xexp-attr))
(define (xexp-attrs theXexp)
  (if (xexp-with-attrs? theXexp) (cdadr theXexp) null))

(: xexp-children : Xexp -> (Listof Xexp))
(define (xexp-children theXexp)
  (cond
    [(xexp-with-attrs? theXexp) (cddr theXexp)]
    [(xexp-no-attrs? theXexp) (cdr theXexp)]
    [else null]))

; &nbsp;	&#160;	 
; &lt;	&#60;	<
; &gt;	&#62;	>
; &amp;	&#38;	&
; &quot;	&#34;	"
; &apos;	&#39;	'
; &cent;	&#162;	¢
; &pound;	&#163;	£
; &yen;	&#165;	¥
; &euro;	&#8364;	€
; &copy;	&#169;	©
; &reg;	&#174;	®
(: xexp-short->char : Xexp-short -> Char)
(define (xexp-short->char theXexp)
  (case (cadr theXexp)
    [(nbsp) #\ ] ; yes, there is a unicode nbsp right there

    ; These 5 ones are handled by html-parsing already
    ;[(lt) #\<]
    ;[(gt) #\>]
    ;[(amp) #\&]
    ;[(quot) #\"]
    ;[(apos) #\']

    [(cent) #\¢]
    [(pound) #\£]
    [(yen) #\¥]
    [(euro) #\€]
    [(copy) #\©]
    [(reg) #\®]
    ; The &#160; form is already handled by html-parsing, but here's where it
    ; would go
    [else
     (log-error (format "Unknown html escape: ~a" (cadr theXexp)))
     #\uFFFD]))
