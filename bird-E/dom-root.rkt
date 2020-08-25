#lang typed/racket/base
(require typed/racket/class "../consoleFeedback.rkt" "../xexp-type.rkt" "node.rkt")
(provide Dom-Root-Node% dom-root-node%)
(define-type Dom-Root-Node% (Class #:implements Node%
                                   (init [initial-tree Xexp])))
(define dom-root-node% : Dom-Root-Node%
  (class node%
    (init [initial-tree : Xexp])
    (print-info "dom-root-node% initted!")
    (println initial-tree)
    (super-new)))
