#lang typed/racket/base
(require typed/racket/date)
(provide print-info
         print-warning
         print-error
         get-verbosity
         set-verbosity!
         VerbosityLevel)
; Print information, warnings, and the like to the console that this was run
; from

(define-type VerbosityLevel
             (U 'all 'errors 'warnings 'errors-and-warnings 'none))
(: verbosity VerbosityLevel)
(define verbosity 'all)
(: get-verbosity (-> VerbosityLevel))
(define (get-verbosity) verbosity)
(: set-verbosity! (-> VerbosityLevel Void))
(define (set-verbosity! new-verbosity)
  (unless (eq? verbosity new-verbosity)
    (let ([info-before (format "Verbosity changing from ~a to ~a"
                               verbosity
                               new-verbosity)]
          [info-after (format "Verbosity changed from ~a to ~a"
                              verbosity
                              new-verbosity)])
      ; NOTE I am printing it before and after so one can tell for certian when
      ; what change happened if it was to or from all mode.
      (print-warning info-before)
      (set! verbosity new-verbosity)
      (print-warning info-after)
      )))

(define (getDisplayTime)
  (date-display-format 'iso-8601) 
  (date->string (current-date) #t))

(define-type PrintThingy (-> String Void))

(: print-info PrintThingy)
(define (print-info information)
  (when (eq? verbosity 'all)
    (displayln (format "[~a] INFO:    ~a" (getDisplayTime) information))))

(: print-warning PrintThingy)
(define (print-warning information)
  (when (or (eq? verbosity 'all)
            (eq? verbosity 'warnings)
            (eq? verbosity 'errors-and-warnings))
    (displayln (format "[~a] WARNING: ~a" (getDisplayTime) information))))

(: print-error PrintThingy)
(define (print-error information)
  (when (or (eq? verbosity 'all)
            (eq? verbosity 'errors)
            (eq? verbosity 'errors-and-warnings))
    (displayln (format "[~a] ERROR:   ~a" (getDisplayTime) information)
               (current-error-port))))
(print-info (format "Verbosity level is currently ~a" verbosity))
