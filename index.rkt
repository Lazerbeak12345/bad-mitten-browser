#lang racket
(require "consoleFeedback.rkt")
(print-info "Opening Bad-Mitten Browser...")

(print-warning "Opening test.html, as I don't know how to do command line args")
(require "bm-window.rkt")
;(new bm-window% [links "test.html"])
(new bm-window% [links '("test.html" "test.html" "invalid.html")])

