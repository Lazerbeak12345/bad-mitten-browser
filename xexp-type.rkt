#lang typed/racket/base
(module xexp-contracts racket/base
  #| This module is only here because I coudln't figure out a better way to
  allow for types that can be used as contracts in runtime and in
  compile-time |#
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
  (define/contract xexp-with-attrs?
				   contract?
					 (cons/c symbol? (cons/c xexp-attrs? (listof xexp?))))
  (define/contract xexp-no-attrs? contract? (cons/c symbol? (listof xexp?)))
  (define/contract (xexp-name theXexp) (-> xexp? symbol?)
				   (car theXexp))
  (define/contract (xexp-attrs theXexp) (-> xexp? (listof (or/c (list/c symbol?)
																(list/c symbol? string?))))
				   (if (xexp-with-attrs? theXexp)
					 (cdadr theXexp)
					 null))
  (define/contract (xexp-children theXexp) (-> xexp? (listof xexp?))
				   (if (xexp-with-attrs? theXexp)
					 (cddr theXexp)
					 (cdr theXexp)))
  (provide xexp-decl?
		   xexp-short?
		   ;xexp-attrs?
		   xexp-with-attrs?
		   xexp-no-attrs?
		   xexp?
		   xexp-name
		   xexp-attrs
		   xexp-children))
(require/typed/provide 'xexp-contracts
					   [#:opaque Xexp-decl xexp-decl?]
					   [#:opaque Xexp-short xexp-short?]
					   ;[#:opaque Xexp-attrs xexp-attrs?]
					   [#:opaque Xexp-with-attrs xexp-with-attrs?]
					   [#:opaque Xexp-no-attrs xexp-no-attrs?]
					   [#:opaque Xexp xexp?]
					   [xexp-name (-> Xexp Symbol)]
					   [xexp-attrs (-> Xexp (Listof (U (List Symbol)
													   (List Symbol String))))]
					   [xexp-children (-> Xexp (Listof Xexp))])
(require "consoleFeedback.rkt")
(provide xexp-short->char)
(: xexp-short->char (-> Xexp-short Char))
(define (xexp-short->char theXexp)
  (print-error "xexp-short->char not written yet")
  #\?)

