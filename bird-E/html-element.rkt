#lang typed/racket/base
(require typed/racket/class
         "../consoleFeedback.rkt"
         "../xexp-type.rkt"
         "element.rkt")
(provide HTML-Element% html-element% xexp->html-element%)
; TODO this should be an interface.
(define-type HTML-Element% (Class #:implements/inits Element%))
(define html-element% : HTML-Element%
  (class element%
    (print-info "HTML-element initted!")
    (super-new)))
(: xexp->html-element% (-> Xexp (Instance HTML-Element%)))
(define (xexp->html-element% xexp)
  (print-info (format "xexp ~v" xexp))
  (if (list? xexp)
    (if (eq? '*DECL* (car xexp))
      (new html-element% ; TODO docstring
           [tag-name-symbol (car xexp)]
           [children (for/list ([child-xexp (cdr xexp)])
                       (new html-element%
                            [tag-name-symbol '*COMMENT*]
                            [children null]))])
      (new html-element%
           [tag-name-symbol (car xexp)]
           [children (for/list ([child-xexp (cdr xexp)])
                       (xexp->html-element% child-xexp))]))
    (new html-element% ; TODO string
         [tag-name-symbol '*COMMENT*]
         [children null])))
