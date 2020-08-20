#lang typed/racket/base
(provide on-evt)
; Call f with the value resolved from evt every time evt resolves in a thread.
; Returns the thread for canceling purposes.
(: on-evt (-> (Evtof Any) (-> Any Void) Thread))
(define (on-evt evt f)
  (thread (λ ()
             ; It's a little faster when you don't need to pass values
             (let loop ()
               (f (sync evt))
               (loop)))))
