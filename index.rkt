#lang racket
(require "consoleFeedback.rkt")
(print-info "Opening Bad-Mitten Browser...")

(print-warning "Opening test.html, as I don't know how to do command line args")
(require "gui.rkt")
(bm-window "test.html")
;(bm-window '("test.html" "test.html"))

