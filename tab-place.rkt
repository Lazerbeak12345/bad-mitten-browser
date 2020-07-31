#lang racket/base
(require racket/contract
         racket/bool
         racket/list
         racket/place
         racket/async-channel
         net/url
         "consoleFeedback.rkt"
         "networking.rkt")
(provide make-tab-place on-evt)
(define/contract
  (on-evt evt f)
  (-> evt? (-> any/c void?) thread?)
  (thread (λ ()
             ; It's a little faster when you don't need to pass values
             (let loop ()
               (f (sync evt))
               (loop)))))
(define/contract
  (make-tab-place) (-> place?)
  (place
    this-place
    (print-info "Entering OS-Level Thread")
    (when (not (place-enabled?))
      (print-error
        (string-append "Places aren't supported in this enviroment. Tabs will"
                       " NOT be run in parallel.")))
    (set-verbosity! (place-channel-get this-place))
    (define/contract theUrl url?
                     (string->url (place-channel-get this-place)))
    (print-info (format "Recived URL: ~a" (url->string theUrl)))
    (define/contract
      (makeInitTree) (-> list?)
      (let loop ([redirectionMax 10])
        (define changedUrl #f)
        (let ([tree
                (htmlTreeFromUrl
                  theUrl
                  (lambda (newUrlStr)
                    (print-info (format "Redirect to ~a" newUrlStr))
                    (set! changedUrl (combine-url/relative theUrl newUrlStr))))])
          (when changedUrl
            (if (< 0 redirectionMax)
              (begin
                (set! theUrl changedUrl)
                (place-channel-put this-place
                                   `(redirect ,(url->string changedUrl)))
                (loop (- redirectionMax 1)))
              (print-info "Hit max redirect!")))
          tree)))
    (define/contract initTree list? (makeInitTree))
    (print-info (format "Tree: ~v" initTree))
    (thread-wait
      (on-evt
        this-place
        (lambda (v)
          (case (first v)
            [(focus unfocus)
             (print-error "Can't actually change CSS and JS clocks")]
            [(set-url)
             (set! theUrl (string->url (second v)))
             (set! initTree (makeInitTree))
             (print-info (format "New Tree: ~v" initTree))
             (print-error "Can't actually refresh CSS and JS!")]
            [else (print-error (format "Invalid message to place: ~a" v))]))))))
