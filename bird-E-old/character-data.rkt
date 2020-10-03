#lang typed/racket/base
(require typed/racket/class "../consoleFeedback.rkt" "node.rkt")
(provide Character-Data% character-data%)
(define-type Character-Data% (Class #:implements Node%
                                    (init [text-content String])))
(define character-data%
  (class node%
    (init [text-content : String])
    (print-info "character-data% initted!")
    (super-new [children null]
               [text-content text-content])))
