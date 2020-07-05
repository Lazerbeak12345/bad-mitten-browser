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

(define/contract verbosity-level? contract?
                 (or/c 'all 'errors 'warnings 'errors-and-warnings 'none)
                 )
(define/contract verbosity verbosity-level? 'all)
(define/contract (get-verbosity) (-> verbosity-level?) verbosity)
(define/contract (set-verbosity! new-verbosity) (-> verbosity-level? void?)
                 (let ([info-before (format "Verbosity changing from ~a to ~a"
                                            verbosity
                                            new-verbosity
                                            )
                                    ]
                       [info-after (format "Verbosity changed from ~a to ~a"
                                           verbosity
                                           new-verbosity
                                           )
                                   ]
                       )
                   ; NOTE I am printing it before and after so one can tell for
                   ; certian when what change happened if it was to or from all
                   ; mode.
                   (print-warning info-before)
                   (set! verbosity new-verbosity)
                   (print-warning info-after)
                   )
                 )

(define/contract 
  (print-info information)
  (string? . -> . void?)
  (when (eq? verbosity 'all)
    (pretty-display (string-append "INFO:    " information))
    )
  )

(define/contract 
  (print-warning information)
  (string? . -> . void?)
  (when (or (eq? verbosity 'all)
            (eq? verbosity 'warnings)
            (eq? verbosity 'errors-and-warnings)
            )
    (pretty-display (string-append "WARNING: " information))
    )
  )

(define/contract 
  (print-error information)
  (string? . -> . void?)
  (when (or (eq? verbosity 'all)
            (eq? verbosity 'errors)
            (eq? verbosity 'errors-and-warnings)
            )
    (pretty-display (string-append "ERROR:   " information))
    )
  )
(print-info (format "Verbosity level is currently ~a" verbosity))

