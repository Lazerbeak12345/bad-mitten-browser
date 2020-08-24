#lang typed/racket/base
(require typed/racket/class "../consoleFeedback.rkt")
; NOTE these _will_ clash with racket/gui
(provide event% Event%)
(define-type Event%
             (Class (init [type String])))
(define event%
  (class object%
    (print-info "event% initted!")
    (super-new)))
