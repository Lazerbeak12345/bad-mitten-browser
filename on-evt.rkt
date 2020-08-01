#lang racket/base
(require racket/contract)
(provide on-evt)
; Call f with the value resolved from evt every time evt resolves in a thread.
; Returns the thread for canceling purposes.
(define/contract
  (on-evt evt f)
  (-> evt? (-> any/c void?) thread?)
  (thread (λ ()
             ; It's a little faster when you don't need to pass values
             (let loop ()
               (f (sync evt))
               (loop)))))
