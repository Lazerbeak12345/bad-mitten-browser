#lang typed/racket/base
(require typed/racket/class "../consoleFeedback.rkt" "character-data.rkt")
(provide Text% text%)
(define-type Text% (Class #:implements/inits Character-Data%))
(define text%
  (class character-data%
    (print-info "text% initted!")
    (super-new)))
