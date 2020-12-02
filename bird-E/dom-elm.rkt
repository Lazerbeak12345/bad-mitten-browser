#lang typed/racket/base
(require typed/racket/class
		 typed/racket/gui/base
		 "../consoleFeedback.rkt"
		 "../xexp-type.rkt")
(provide dom-elm% Dom-Elm%)
(define-type Dom-Elm% (Class
						#:implements/inits Editor-Snip%
						(init [name (U Symbol String)]
							  [attrs (Listof (U (List Symbol)
												(List Symbol String)))]
							  [children (Listof Any)]))) ; TODO fix
(define dom-elm% : Dom-Elm%
  (class editor-snip%
    (init name attrs children)
    (super-new)
	(define init-name : (U Symbol String) name)
	(define init-attrs : (Listof (U (List Symbol)
									(List Symbol String))) attrs)
	(define init-children : (Listof Any) children)
	(print-info (format "children: ~a" init-children))))

