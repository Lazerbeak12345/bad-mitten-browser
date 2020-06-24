#lang racket
(require racket/gui/base)
; The code for a single tab (only)

(require "consoleFeedback.rkt")

(define/contract
  (tab tab-link frame locationBox) (string?
									 (is-a?/c frame%)
									 (is-a?/c text-field%)
									 . -> .
									 void?
									 )
  ;TODO on focus, (send locationBox set-value tablink)
  (print-info (string-append "Opening tab '" tab-link "'"))
  )
(provide tab)
