#lang typed/racket/base
(require typed/racket/class "../consoleFeedback.rkt" "element.rkt")
(provide HTML-Element% HTML-element%)
(define-type HTML-Element% (Class #:implements Element%))
(define HTML-element%
  (class element%
    (print-info "HTML-element initted!")
    (super-new)))
