#lang typed/racket/base
; TODO this is a stub
(require typed/racket/class "../consoleFeedback.rkt" "../xexp-type.rkt")
(provide dom-elm% Dom-Elm%)
(define-type Dom-Elm% (Class (init [name (U Symbol String)]
                                   [attrs (Listof (U (List Symbol)
                                                     (List Symbol String)))]
                                   [children (Listof Any)]))) ; TODO fix
(define dom-elm% : Dom-Elm%
  (class object%
    (init name attrs children)
    (super-new)
    (print-warning "dom-elm% not written yet")))
