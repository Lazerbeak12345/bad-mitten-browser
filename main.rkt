#lang racket/base
(module+ test
  ;(print-error "No tests written!?")
  #f)
(module+ main
  (require racket/class "consoleFeedback.rkt" "bm-window.rkt")
  (print-info "Opening Bad-Mitten Browser…")
  ; This is converting it into a list
  (new bm-window% [links (for/list ([arg (current-command-line-arguments)])
                           arg)]))
