#lang typed/racket/base
(require typed/racket/class "../consoleFeedback.rkt" "node.rkt")
(provide Element% element%)
(define-type Element% (Class #:implements Node%))
(define element%
  (class node%
    (print-info "element% initted!")
    (super-new)))
