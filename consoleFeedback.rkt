#lang racket
(provide print-info
         print-warning
         print-error
         get-verbosity
         set-verbosity!
         verbosity-level?
         )
; Print information, warnings, and the like to the console that this was run
; from

(define verbosity-level?
  (or/c 'all 'errors 'warnings 'errors-and-warnings 'none)
  )
(define/contract verbosity verbosity-level 'all)
(define/contract (get-verbosity) (-> verbosity-level?) verbosity)
(define/contract (set-verbosity! new-verbosity) (-> verbosity-level? void?)
                 (let ([info (format "Verbosity changed to ~a from ~a"
                                     new-verbosity
                                     verbosity
                                     )
                             ]
                       )
                   (set! verbosity new-verbosity)
                   (print-info info)
                   )
                 )

(define/contract 
  (print-info information)
  (string? . -> . void?)
  (when (equal? verbosity 'all)
    (pretty-display (string-append "INFO:    " information))
    )
  )

(define/contract 
  (print-warning information)
  (string? . -> . void?)
  (when (or (equal? verbosity 'all)
            (equal? verbosity 'warnings)
            (equal?  verbosity 'errors-and-warnings)
            )
    (pretty-display (string-append "WARNING: " information))
    )
  )

(define/contract 
  (print-error information)
  (string? . -> . void?)
  (when (or (equal? verbosity 'all)
            (equal? verbosity 'errors)
            (equal?  verbosity 'errors-and-warnings)
            )
    (pretty-display (string-append "ERROR:   " information))
    )
  )

