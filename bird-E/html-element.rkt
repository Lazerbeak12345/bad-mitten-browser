#lang typed/racket/base
(require typed/racket/class
         racket/format
         "../consoleFeedback.rkt"
         "../xexp-type.rkt"
         "element.rkt"
         "text.rkt")
(provide HTML-Element% html-element% xexp->html-element%)
; TODO this should be an interface.
(define-type HTML-Element% (Class #:implements/inits Element%))
(define html-element% : HTML-Element%
  (class element%
    (print-info "HTML-element initted!")
    (super-new)))
(: xexp->html-element% (-> Xexp (U (Instance HTML-Element%)
                                   (Instance Text%))))
(define (xexp->html-element% xexp)
  (print-info (format "xexp ~v" xexp))
  (cond
    [(list? xexp)
     (if (eq? '*DECL* (car xexp))
       (new html-element% ; TODO docstring
            [tag-name-symbol '*DECL*]
            [children (list (new text% [text-content (~a (cdr xexp))]))])
       (new html-element%
            [tag-name-symbol (car xexp)]
            [children (for/list ([child-xexp (xexp-children xexp)])
                        (xexp->html-element% child-xexp))]))]
     [else (new text% [text-content xexp])]))
