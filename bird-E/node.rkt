#lang typed/racket/base
(require typed/racket/class "../consoleFeedback.rkt" "eventTarget.rkt")
(provide Node% node%)
; TODO add getpict or something
(define-type Node% (Class #:implements Event-Target%
                          (field [childNodes (Listof (Instance Node%))])))
(define node% : Node%
  (class event-target%
    (field [childNodes null])
    (print-info "node% initted!")
    (super-new)))
