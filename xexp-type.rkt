#lang typed/racket/base
(module xexp-contracts racket/base
  (require racket/contract)
  (define/contract xexp-decl? contract?
				   (cons/c '*DECL* (listof (or/c string? symbol?))))
  (define/contract xexp-short? contract?
				   (list/c '& (or/c string? symbol?)))
  (define/contract xexp-attrs? contract?
				   (cons/c '@ (listof (or/c (list/c symbol?)
											(list/c symbol? string?)))))
  (define/contract (xexp? e)
				   contract?
				   ((flat-contract-predicate (or/c string?
												   xexp-decl?
												   xexp-short?
												   xexp-with-attrs?
												   xexp-no-attrs?)) e))
  #|(define/contract xexp-with-attrs?
				   contract?
				   (flat-contract-predicate (*list/c symbol? xexp-attrs? xexp?)))|#
  (define/contract xexp-with-attrs?
				   contract?
				   ;(flat-contract-predicate
					 (cons/c symbol? (cons/c xexp-attrs? (listof xexp?))));)
  (define/contract xexp-no-attrs? contract? (cons/c symbol? (listof xexp?)))
  (provide xexp-decl?
		   xexp-short?
		   ;xexp-attrs?
		   xexp-with-attrs?
		   xexp-no-attrs?
		   xexp?))
(require/typed/provide 'xexp-contracts
					   [#:opaque Xexp-decl xexp-decl?]
					   [#:opaque Xexp-short xexp-short?]
					   ;[#:opaque Xexp-attrs xexp-attrs?]
					   [#:opaque Xexp-with-attrs xexp-with-attrs?]
					   [#:opaque Xexp-no-attrs xexp-no-attrs?]
					   [#:opaque Xexp xexp?])
(require "consoleFeedback.rkt")
(provide xexp-attrs xexp-children xexp-name)
(: xexp-children (-> Xexp (Listof Xexp)))
(define (xexp-children theXexp)
  (print-error "xexp-children needs a refresh")
  null)
#|(define (xexp-children theXexp)
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
        [else (cdr theXexp)]))|#
(: xexp-name (-> Xexp Symbol))
(define (xexp-name theXexp)
  (print-error "xexp-name not written yet")
  'todo)
(: xexp-attrs (-> Xexp (Listof (U (List Symbol)
                                  (List Symbol String)))))
(define (xexp-attrs theXexp)
  (print-error "xexp-name not written yet")
  null)

