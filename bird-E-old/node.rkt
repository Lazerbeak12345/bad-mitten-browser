#lang typed/racket/base
(require typed/racket/class "../consoleFeedback.rkt" "eventTarget.rkt")
(provide Node% node%)
; TODO add getpict or something
(define-type Node% (Class #:implements Event-Target%
                          (init-field [children (Listof (Instance Node%))]
                                      [text-content String #:optional])))
(define node% : Node%
  (class event-target%
    (init-field children [text-content ""])
    (print-info "node% initted!")
    (super-new)))
