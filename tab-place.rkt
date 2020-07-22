#lang racket/base
(require racket/contract
         racket/bool
         racket/list
         racket/place
         racket/async-channel
         net/url
         "consoleFeedback.rkt"
         )
(provide make-tab-place blocking-loop->async place-channel->async)
; This makes it so I don't have to block if there isn't a value yet.
; NOTE: Sending something to the thread will be delayed until after f returns
(define/contract
  (blocking-loop->async f)
  (-> (-> (or/c false? any/c) any/c) (values async-channel? thread?))
  (let ([ch (make-async-channel)])
    (values ch (thread (λ ()
                          (let loop ()
                            (async-channel-put ch (f (thread-try-receive)))
                            (loop)
                            )
                          )
                       )
            )
    )
  )
; Make a way of interacting with channel stuff without needing to wait for
; anything
; NOTE: Sending something to the thread will be delayed until after the place
; sends something.
(define/contract
  (place-channel->async p) (-> place-channel? (values async-channel? thread?))
  (blocking-loop->async (λ (v) (if v
                                   (place-channel-put/get p v)
                                   (place-channel-get p)
                                   )
                           )
                        )
  )
(define/contract
  (make-tab-place) (-> place?)
  (place
    this-place
    (print-info "Entering OS-Level Thread")
    (when (not (place-enabled?))
      (print-error
        (string-append "Places aren't supported in this enviroment. Tabs will"
                       " NOT be run in parallel."
                       )
        )
      )
    (define/contract theUrl (or/c null? url?) '())
    (set-verbosity! (place-channel-get this-place))
    (let ([rUrl (place-channel-get this-place)])
      (print-info (format "Recived URL: ~a" rUrl))
      (set! theUrl (string->url rUrl))
      )
    (define-values (ch th) (place-channel->async this-place))
    (let loop ()
      (sync ; This is behaving like a case over events
        (handle-evt
          ch
          (lambda (v)
            (case (first v)
              [(close)
               (print-error "Doesn't trigger JS events or any of that stuff")
               (place-channel-put this-place #t)
               ]
              [(focus unfocus)
               (print-error "Can't actually change CSS and JS clocks")
               ]
              [else (print-error (format "Invalid message to place: ~a" v))]
              )
            )
          )
        )
      ; Eh, may as well just loop here. I don't want to think about the
      ; possibliity of the loop forking. (the double-event firing alone would
      ; be a beast)
      (loop)
      )
    )
  )
