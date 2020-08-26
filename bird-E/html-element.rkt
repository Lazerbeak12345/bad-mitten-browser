#lang typed/racket/base
(require typed/racket/class
         "../consoleFeedback.rkt"
         "../xexp-type.rkt"
         "element.rkt")
(provide HTML-Element% html-element% xexp->html-element%)
; TODO this should be an interface.
(define-type HTML-Element% (Class #:implements Element%))
(define html-element% : HTML-Element%
  (class element%
    (print-info "HTML-element initted!")
    (super-new)))
(: xexp->html-element% (-> Xexp (Instance HTML-Element%)))
(define (xexp->html-element% xexp)
  ; lol. It's so useless right now.
  (new html-element%))
