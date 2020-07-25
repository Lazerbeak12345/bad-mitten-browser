#lang racket/base
; The code for a single tab
(require racket/gui/base
         racket/contract
         racket/class
         racket/list
         racket/place
         net/url
         "consoleFeedback.rkt"
         "tab-place.rkt"
         )
(provide tab%)
(current-url-encode-mode 'unreserved)
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
  (class object%
    (init url locationBox locationBack locationForward tab-panel update-title)
    (define self-url url)
    (define ext-locationBox locationBox)
    (define ext-locationBack locationBack)
    (define ext-locationForward locationForward)
    (define ext-tab-panel tab-panel)
    (define ext-update-title update-title)
    (define title null) ; When null get-title will default to the url
    (define history '())
    (define history-future '())
    (define hasBeenFocused #f) ; Has this tab been focused already?
    (define tab-place '())
    (define tab-place-event-th '())
    (define/private (url->readable self-url) (url->string self-url))
    (define/private (initRenderer)
      (print-info (format "Starting renderer on ~a" (url->string self-url)))
      (clean)
      (unless (null? tab-place)
        (print-warning "Closing from within init")
        (close)
        )
      (set! tab-place (make-tab-place))
      ; Make sure the logging isn't too verbose
      (place-channel-put tab-place (get-verbosity))
      ; What URL?
      (place-channel-put tab-place (url->string self-url))
      (set! tab-place-event-th
        (thread (lambda ()
                  (on-evt tab-place
                          (lambda (v)
                            (case (first v)
                              [(redirect)
                               (print-info (format
                                             "Redirect url '~a' to '~a'"
                                             (url->string self-url)
                                             (second v)
                                             )
                                           )
                               (clean)
                               (send ext-locationBox set-value (second v))
                               (set! self-url (string->url (second v)))
                               (ext-update-title)
                               ]
                              [(update-title)
                               (set! title (second v))
                               (ext-update-title)
                               ]
                              [else (print-error
                                      (format "Unknown event ~a" v)
                                      )
                                    ]
                              )
                            )
                          )
                  )
                )
        )
      )
    ;place for tab to be rendered upon
    (define thisPanel (new panel% [parent ext-tab-panel] [style '(deleted)]))
    (define/private (updateLocationButtons)
      (print-info "Updating location buttons")
      (send ext-locationBack enable (not (null? history)))
      (send ext-locationForward enable (not (null? history-future)))
      )
    (define/private (clean)
      (print-info "Cleaning…")
      (set! title null)
      (ext-update-title)
      (send thisPanel change-children (lambda (current) '()))
      (updateLocationButtons)
      )
    (super-new)
    (define/public (close)
      (print-info (format "Closing ~a" (url->string self-url)))
      (place-kill tab-place)
      (kill-thread tab-place-event-th)
      )
    (define/public (locationChanged)
      (let ([new-url (netscape/string->url (send ext-locationBox get-value))])
        (if (equal? self-url new-url)
          (print-warning "Url value didn't change")
          (begin
            (print-info (format "Changing '~a' to '~a'"
                                (url->string self-url)
                                (url->string new-url)
                                )
                        )
            (send ext-locationBox set-value (url->string new-url))
            (set! history (cons self-url history))
            (set! history-future '())
            (set! self-url new-url)
            (initRenderer)
            )
          )
        )
      )
    (define/public (focus)
      (print-info (format "Focusing '~a'" (url->string self-url)))
      (unless hasBeenFocused
        (initRenderer)
        (set! hasBeenFocused #t)
        )
      (send ext-locationBox set-value (url->string self-url))
      (send ext-tab-panel add-child thisPanel)
      (updateLocationButtons)
      (place-channel-put tab-place '(focus))
      )
    (define/public (unfocus)
      (print-info (format "Unfocusing '~a'" (url->string self-url)))
      (send ext-tab-panel delete-child thisPanel)
      (place-channel-put tab-place '(unfocus))
      )
    (define/public (reload)
      (print-info (format "Reloading '~a'" (url->string self-url)))
      (initRenderer)
      )
    (define/public (back)
      (print-info (format "Going back on '~a'" (url->string self-url)))
      (let ([new-url (first history)])
        (send ext-locationBox set-value (url->string new-url))
        (set! history (cdr history))
        (set! history-future (cons self-url history-future))
        (set! self-url new-url)
        (initRenderer)
        )
      )
    (define/public (forward)
      (print-info (format "Going forward on '~a'" (url->string self-url)))
      (let ([new-url (first history-future)])
        (send ext-locationBox set-value (url->string new-url))
        (set! history (cons self-url history))
        (set! history-future (cdr history-future))
        (set! self-url new-url)
        (initRenderer)
        )
      )
    (define/public (get-title) 
      (let ([title (if (null? title)
                     (url->readable self-url)
                     title
                     )
                   ]
            )
        (if (< 30 (string-length title))
          (format "~a…" (substring title 0 (- 30 1)))
          title
          )
        )
      )
    (define/public (get-url) self-url)
    )
  )
