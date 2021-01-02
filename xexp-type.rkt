#lang typed/racket/base
(require "consoleFeedback.rkt")
(define-type Xexp-decl (Pair '*DECL* (Listof (U String Symbol))))
(define-predicate xexp-decl? Xexp-decl)
(provide xexp-decl? Xexp-decl)

(define-type Xexp-short (List '& (U String Symbol)))
(define-predicate xexp-short? Xexp-short)
(provide xexp-short? Xexp-short)

(define-type Xexp-attr (U (List Symbol)
                          (List Symbol String)))
(define-predicate xexp-attr? Xexp-attr)
(provide xexp-attr? Xexp-attr)

(define-type Xexp-attrs (Pair '@ (Listof Xexp-attr)))
(define-predicate xexp-attrs? Xexp-attrs)
(provide xexp-attrs? Xexp-attrs)

(define-type Xexp-with-attrs (Pair Symbol (Pair Xexp-attrs (Listof Xexp))))
(define-predicate xexp-with-attrs? Xexp-with-attrs)
(provide xexp-with-attrs? Xexp-with-attrs)

(define-type Xexp-no-attrs (Pair Symbol (Listof Xexp)))
(define-predicate xexp-no-attrs? Xexp-no-attrs)
(provide xexp-no-attrs? Xexp-no-attrs)

(define-type Xexp (U String
                     Xexp-decl
                     Xexp-short
                     Xexp-with-attrs
                     Xexp-no-attrs))
(define-predicate xexp? Xexp)
(provide xexp? Xexp)

(provide xexp-name xexp-attrs xexp-children xexp-short->char)

; First arg is any Xexp that is not a string
(: xexp-name (-> (U Xexp-decl
                    Xexp-short
                    Xexp-with-attrs
                    Xexp-no-attrs)
                 Symbol))
(define (xexp-name theXexp)
  (car theXexp))

(: xexp-attrs (-> Xexp (Listof Xexp-attr)))
(define (xexp-attrs theXexp)
  (if (xexp-with-attrs? theXexp)
    (cdadr theXexp)
    null))

(: xexp-children (-> Xexp (Listof Xexp)))
(define (xexp-children theXexp)
  (cond [(xexp-with-attrs? theXexp)
         (cddr theXexp)]
        [(xexp-no-attrs? theXexp)
         (cdr theXexp)]
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
(: xexp-short->char (-> Xexp-short Char))
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
    [else (print-error (format "Unknown html escape: ~a" (cadr theXexp)))
          #\uFFFD]))

