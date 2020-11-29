#!/usr/bin/env racket
#lang typed/racket/base
(module+ test
  ;(print-error "No tests written!?")
  #f)
(module+ main
  (require typed/racket/class "consoleFeedback.rkt" "bm-window.rkt")
  (print-info "Opening Bad-Mitten Browser…")
  (new bm-window% [links (vector->list (current-command-line-arguments))]))

