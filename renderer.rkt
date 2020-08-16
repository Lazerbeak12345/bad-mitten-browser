#lang racket/base
(require racket/gui/base racket/class "consoleFeedback.rkt")
(provide make-canvas)
(define (make-canvas parent)
  (new
    canvas%
    [parent parent]
    [style '(no-autoclear)]))
