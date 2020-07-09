#lang racket
; The code for a single tab
(require racket/gui/base net/url "consoleFeedback.rkt" "networking.rkt")
(provide tab%)
(define/contract
  tab%
  (class/c
    (init [url url?]
          [locationBox (is-a?/c text-field%)]
          [locationBack (is-a?/c button%)]
          [locationForward (is-a?/c button%)]
          [tab-panel (is-a?/c tab-panel%)]
          [update-title (-> void?)]
          )
    [close (->m void?)]
    [locationChanged (->m void?)]
    [focus (->m void?)]
    [unfocus (->m void?)]
    [unfocus (->m void?)]
    [reload (->m void?)]
    [back (->m void?)]
    [forward (->m void?)]
    [get-title (->m string?)]
    [get-url (->m url?)]
    )
  (class object% (init url
                       locationBox
                       locationBack
                       locationForward
                       tab-panel
                       update-title
                       )
    (define self-url url)
    ;Default to the URL TODO migrate
    (define self-title (url->readable self-url))
    (define self-locationBox locationBox)
    (define self-locationBack locationBack)
    (define self-locationForward locationForward)
    (define self-tab-panel tab-panel)
    (define self-update-title update-title)
    (define history '())
    (define history-future '())
    (define/private (url->readable self-url) (url->string self-url))
    (define/private (parse [redirectionMax 10])
      (print-info (format "Parsing ~a" (url->string self-url)))
      (define changedUrl #f)
      (let ([tree
              (htmlTreeFromUrl
                self-url
                (lambda (newUrlStr)
                  (print-info (format "Plan to redirect to ~a" newUrlStr))
                  (set! changedUrl (combine-url/relative self-url newUrlStr))
                  )
                )
              ]
            )
        (new message% ; TODO Temporary for debugging use.
             [parent thisPanel]
             [label (let ([str (~a tree)])
                      (if (> (string-length str) 200)
                        (format "~a..." (substring str 0 (- 200 3)))
                        str)
                      )
                    ]
             )
        (when changedUrl
          (if (< 0 redirectionMax)
            (begin
              (print-info (format "Redirecting '~a' to '~a'"
                                  (url->string self-url)
                                  (url->string changedUrl)
                                  )
                          )
              (send self-locationBox set-value (url->string changedUrl))
              (set! self-url changedUrl)
              (set! self-title (url->readable self-url))
              (self-update-title)
              (clean)
              (parse (- redirectionMax 1))
              )
            (print-info "Hit max redirect!")
            )
          )
        )
      )
    (super-new)
    ;place for tab to be rendered upon
    (define thisPanel
      (new panel% [parent self-tab-panel] [style '(deleted)])
      )
    (define/private (updateLocationButtons)
      (send self-locationBack enable (not (null? history)))
      (send self-locationForward enable (not (null? history-future)))
      )
    (define/private (clean)
      (send thisPanel change-children (lambda (current) '()))
      (updateLocationButtons)
      )
    (define/public (close)
      (print-error "Doesn't trigger JS events or any of that stuff")
      )
    (define/public (locationChanged)
      (define new-url
        (netscape/string->url (send self-locationBox get-value))
        )
      (if (equal? self-url new-url)
        (print-warning "Url value didn't change")
        (begin
          (print-info (format "Changing '~a' to '~a'"
                              (url->string self-url)
                              (url->string new-url)
                              )
                      )
          (send self-locationBox set-value (url->string new-url))
          (set! history (cons self-url history))
          (set! history-future '())
          (set! self-url new-url)
          (set! self-title (url->readable self-url))
          (self-update-title)
          (clean)
          (parse)
          )
        )
      )
    (define/public (focus)
      (print-info (format "Focusing '~a'" (url->string self-url)))
      (send self-locationBox set-value (url->string self-url))
      (send self-tab-panel add-child thisPanel)
      (updateLocationButtons)
      ; TODO Speed up CSS and JS clocks
      (print-error "Can't actually change CSS and JS clocks")
      )
    (define/public (unfocus)
      (print-info (format "Unfocusing '~a'" (url->string self-url)))
      (send self-tab-panel delete-child thisPanel)
      ; TODO Slow down CSS and JS clocks
      (print-error "Can't actually change CSS and JS clocks")
      )
    (define/public (reload)
      (print-info (format "Reloading '~a'" (url->string self-url)))
      (clean)
      (parse)
      )
    (define/public (back)
      (print-info (format "Going back on '~a'" (url->string self-url)))
      (let ([new-url (first history)])
        (send self-locationBox set-value (url->string new-url))
        (set! history (cdr history))
        (set! history-future (cons self-url history-future))
        (set! self-url new-url)
        (set! self-title (url->readable self-url))
        (self-update-title)
        (clean)
        (parse)
        )
      )
    (define/public (forward)
      (print-info (format "Going forward on '~a'" (url->string self-url)))
      (let ([new-url (first history-future)])
        (send self-locationBox set-value (url->string new-url))
        (set! history (cons self-url history))
        (set! history-future (cdr history-future))
        (set! self-url new-url)
        (set! self-title (url->readable self-url))
        (self-update-title)
        (clean)
        (parse)
        )
      )
    (define/public (get-title) 
      (if ((string-length self-title) . > . 30)
        (format "~a..." (substring self-title 0 (- 30 3)))
        self-title
        )
      )
    (define/public (get-url) self-url)
    (clean)
    (parse)
    )
  )

