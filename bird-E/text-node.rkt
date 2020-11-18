#lang typed/racket/base
; TODO this is a stub
(require typed/racket/class "../consoleFeedback.rkt")
(provide text-node% Text-Node%)
(define-type Text-Node% (Class (init [text String])))
(define text-node% : Text-Node%
  (class object%
    (init text)
    (super-new)
    (print-warning "text-node% not written yet")))
