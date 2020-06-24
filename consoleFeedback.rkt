#lang racket
; Print information, warnings, and the like to the console that this was run
; from

(define/contract 
  (print-info information)
  (string? . -> . void?)

  (pretty-display (string-append "INFO:    " information))
  )

(define/contract 
  (print-warning information)
  (string? . -> . void?)

  (pretty-display (string-append "WARNING: " information))
  )

(define/contract 
  (print-error information)
  (string? . -> . void?)

  (pretty-display (string-append "ERROR:   " information))
  )

(provide print-info print-warning print-error)

