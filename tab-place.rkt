#lang racket/base
(require racket/contract
         racket/list
         racket/place
         net/url
         "consoleFeedback.rkt"
         "networking.rkt"
         "on-evt.rkt")
(provide make-tab-place)
(define/contract
  (make-tab-place) (-> place?)
  (place
    this-place
    (print-info "Entering OS-Level Thread")
    (unless (place-enabled?)
      (print-error
        (string-append "Places aren't supported in this enviroment. Tabs will"
                       " NOT be run in parallel.")))
    (set-verbosity! (place-channel-get this-place))
    (define/contract theUrl url? (string->url (place-channel-get this-place)))
    (print-info (format "Recived URL: ~a" (url->string theUrl)))
    (define/contract
      (makeInitTree) (-> list?)
      (let loop ([redirectionMax 10])
        (define changedUrl #f)
        (define tree
                (htmlTreeFromUrl
                  theUrl
                  (lambda (newUrlStr)
                    (print-info (format "Redirect to ~a" newUrlStr))
                    (set! changedUrl (combine-url/relative theUrl
                                                           newUrlStr)))))
          (when changedUrl
            (if (< 0 redirectionMax)
              (begin
                (set! theUrl changedUrl)
                (place-channel-put this-place
                                   `(redirect ,(url->string changedUrl)))
                (loop (- redirectionMax 1)))
              (print-info "Hit max redirect!")))
          tree))
    (define/contract initTree list? (makeInitTree))
    (define sharedImageBytes (make-shared-bytes 4))
    (define imageW 1)
    (define imageH 1)
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
            [(canvas-size)
             (set! imageW (second v))
             (set! imageH (third v))
             (set! sharedImageBytes (fourth v))]
            [else (print-error (format "Invalid message to place: ~a"v))]))))))
