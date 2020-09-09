#lang typed/racket/base
(require racket/list)
(provide Xexp xexp-decl? xexp-children)
(define-type Xexp (U Xexp-decl
                     Xexp-short
                     Xexp-with-attrs
                     Xexp-no-attrs
                     String))
(define-type Xexp-decl (Pairof '*DECL* (Listof (U String Symbol))))
(define-type Xexp-short (Pairof '& (Listof (U String Symbol))))
(define-type Xexp-with-attrs (Pairof Symbol (Pairof Xexp-attrs (Listof Xexp))))
(define-type Xexp-attrs (Pairof '@ (Listof (U (List Symbol)
                                              (List Symbol String)))))
(define-type Xexp-no-attrs (Pairof Symbol (Listof Xexp)))
(: xexp-decl? (-> Xexp Boolean))
(define (xexp-decl? theXexp)
  (and (not (string? theXexp))
       (eq? '*DECL* (first theXexp))))
(: xexp-children (-> Xexp (Listof Xexp)))
(define (xexp-children theXexp)
  (cond [(or (string? theXexp)
             (eq? '*DECL* (first theXexp))
             (eq? '& (first theXexp))
             (null? (cdr theXexp)))
         null]
        [(let ([potential-attrs (second theXexp)])
           (and (list? potential-attrs)
                (eq? '@ (first potential-attrs))
                #|(list? (second potential-attrs))
                (list? (first (second potential-attrs)))|#))
         #|(cddr (ann theXexp Xexp-with-attrs))
         (cdr (ann theXexp Xexp-no-attrs))|#
         (cddr theXexp)] ; TODO get more strict once the typing is better
        [else (cdr theXexp)]))
