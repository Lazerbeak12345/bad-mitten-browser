#lang typed/racket/base
(require typed/racket/class "../consoleFeedback.rkt" "node.rkt")
(provide Element% element%)
(define-type Element% (Class #:implements/inits Node%
                             (init-field [tag-name-symbol Symbol])))
(define element% : Element%
  (class node%
    (init-field tag-name-symbol)
    (print-info "element% initted!")
    (super-new)))
