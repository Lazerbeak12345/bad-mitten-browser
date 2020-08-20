#lang typed/racket/base
(require typed/racket/gui/base typed/racket/class "consoleFeedback.rkt")
(provide make-canvas)
(: make-canvas (-> (U (Instance Frame%)
                      (Instance Panel%)
                      (Instance Dialog%) 
                      (Instance Pane%)) (Instance Canvas%)))
(define (make-canvas parent)
  (new
    canvas%
    [parent parent]
    [style '(no-autoclear)]))
