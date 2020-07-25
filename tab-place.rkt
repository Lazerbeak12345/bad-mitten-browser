#lang racket/base
(require racket/contract
         racket/bool
         racket/list
         racket/place
         racket/async-channel
         net/url
         "consoleFeedback.rkt"
         "networking.rkt"
         )
(provide make-tab-place on-evt)
(define (on-evt evt f)
  (let loop () ; It's a little faster when you don't need to pass values
    (f (sync evt))
    (loop)
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
    (set-verbosity! (place-channel-get this-place))
    (define/contract theUrl (or/c null? url?) '())
    (let ([rUrl (place-channel-get this-place)])
      (print-info (format "Recived URL: ~a" rUrl))
      (set! theUrl (string->url rUrl))
      )
    (define/contract
      initTree list?
      (let loop ([redirectionMax 10])
        (define changedUrl #f)
        (let ([tree
                (htmlTreeFromUrl
                  theUrl
                  (lambda (newUrlStr)
                    (print-info (format "Redirect to ~a" newUrlStr))
                    (set! changedUrl (combine-url/relative theUrl newUrlStr))
                    )
                  )
                ]
              )
          (when changedUrl
            (if (< 0 redirectionMax)
              (begin
                (set! theUrl changedUrl)
                (place-channel-put this-place
                                   `(redirect ,(url->string changedUrl))
                                   )
                (loop (- redirectionMax 1))
                )
              (print-info "Hit max redirect!")
              )
            )
          tree
          )
        )
      )
    (print-info (format "Tree: ~v" initTree))
    (on-evt
      this-place
      (lambda (v)
        (case (first v)
          [(focus unfocus)
           (print-error "Can't actually change CSS and JS clocks")
           ]
          [(set-url)
           (print-error "Not written yet!")
           ]
          [else (print-error (format "Invalid message to place: ~a" v))]
          )
        )
      )
    )
  )
