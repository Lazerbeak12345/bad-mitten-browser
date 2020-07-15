#lang racket
; The main window TODO use signatures

; NOTE: I am specifically targeting the GNOME desktop enviroment, and plan to
; follow their official appearance guidelines in the future.
(require racket/gui/base net/url "consoleFeedback.rkt" "tab.rkt") 
(provide bm-window%)
(define/contract
  bm-window%
  (class/c
    (init [links (or/c null? string? (listof string?) url? (listof url?))])
    )
  (class object% (init links)
                     (define self-links
                       (cond [(null? links)
                              (list (netscape/string->url "bm:newtab"))
                              ]
                             [(string? links)
                              (list (netscape/string->url links))
                              ]
                             [((listof string?) links)
                              (for/list [(link links)]
                                (netscape/string->url link)
                                )
                              ]
                             [(url? links) (list links)]
                             [((listof url?) links) links]
                             )
                       )
                     (define label "Bad-Mitten Browser")
                     (define frame (new frame%
                                        [label label]
                                        ; I just guessed these numbers. Works
                                        ; for gnome, works for me
                                        [width 800] 
                                        [height 600]
                                        [alignment '(center top)]
                                        )
                       )
                     (define locationPane (new horizontal-pane% 
                                               ;TODO text align vert-center
                                               [parent frame]
                                               [alignment '(left center)]
                                               )
                       )
                     (send locationPane stretchable-height #f)
                     (define (locationChanged pane event)
                       (when (eq? (send event get-event-type)
                                  'text-field-enter
                                  )
                         (print-info "Location changed!")
                         ; They already have access to the url box
                         (send (getCurrentTab) locationChanged) 
                         )
                       )
                     (define locationBack
                       (new button%
                            [parent locationPane]
                            [label "Back"]
                            [callback (lambda (button event)
                                        (send (getCurrentTab) back)
                                        )
                                      ]
                            )
                       )
                     (define locationForward
                       (new button%
                            [parent locationPane]
                            [label "Forward"]
                            [callback (lambda (button event)
                                        (send (getCurrentTab) forward)
                                        )
                                      ]
                            )
                       )
                     (define locationReload
                       (new button%
                            [parent locationPane]
                            [label "Reload"]
                            [callback (lambda (button event)
                                        (send (getCurrentTab) reload)
                                        )
                                      ]
                            )
                       )
                     ; The location box. I would prefer if this were in the top
                     ; bar instead.
                     (define locationBox (new text-field%
                                              [parent locationPane]
                                              ;[label "URL:"]
                                              [label ""]
                                              [callback locationChanged]
                                              )
                       )
                     (send locationBox stretchable-height #t)
                     (define tabManagerPane (new horizontal-pane%
                                                 [parent frame]
                                                 [alignment '(right center)]
                                                 )
                       )
                     (send tabManagerPane stretchable-height #f)
                     (define/private (makeTab tab-link)
                       (new tab%
                            [url tab-link]
                            [locationBox locationBox]
                            [locationBack locationBack]
                            [locationForward locationForward]
                            [tab-panel tab-elm]
                            [update-title update-title]
                            )
                       )
                     (define/private (get-tab-choices)
                       (for/list ([tab tabs])
                         (send tab get-title)
                         )
                       )
                     (define/private (addTabBtnCallback)
                       (print-info "Making new tab")
                       (set! tabs
                         (append tabs
                                 (list 
                                   (makeTab (netscape/string->url "bm:newtab"))
                                   )
                                 )
                         ) 
                       (send tab-elm set (get-tab-choices))
                       (send tab-elm set-selection (- (length tabs) 1))
                       )
                     (define addTabBtn
                       (new button%
                            [parent tabManagerPane]
                            [label "New Tab"]
                            [callback (lambda (button event)
                                        (send (getCurrentTab) unfocus)
                                        (addTabBtnCallback)
                                        (do-focus)
                                        )
                                      ]
                            )
                       )
                     (define closeTabBtn
                       (new button%
                            [parent tabManagerPane]
                            [label "Close Tab"]
                            [callback 
                              (lambda (button event)
                                (let ([current (getCurrentTab)]) 
                                  (print-info 
                                    (format "Closing ~a"
                                            (send current get-title)
                                            )
                                    )
                                  (send current unfocus)
                                  )
                                (let ([counter -1]
                                      [index (send tab-elm get-selection)])
                                  (send (list-ref tabs index) close)
                                  (set! tabs
                                    (filter (lambda (item)
                                              (set! counter (+ counter 1))
                                              (not (= counter index))
                                              )
                                            tabs
                                            )
                                    )
                                  (send tab-elm set (get-tab-choices))
                                  (if (= 0 (length tabs))
                                    (begin
                                      (print-info "Closing browser!")
                                      (exit 0)
                                      )
                                    (send tab-elm set-selection
                                          (if (= 0 index)
                                            0
                                            (- index 1)
                                            )
                                          )
                                    )
                                  (do-focus)
                                  )
                                )
                              ]
                            )
                       )
                     (let-values ([(width height)
                                   (send closeTabBtn get-graphical-min-size)
                                   ]
                                  )
                       ; (print-info (~a width))
                       (send locationBack min-width width)
                       (send locationForward min-width width)
                       (send locationReload min-width width)
                       (send addTabBtn min-width width)
                       (send closeTabBtn min-width width)
                       )
                     (define last-tab-focused 0)
                     (define tabs null)
                     (define/private (getCurrentTab)
                       (print-info "Getting current tab")
                       (list-ref tabs (send tab-elm get-selection))
                       )
                     (define/private (do-focus)
                       (let ([index (send tab-elm get-selection)])
                         (send (list-ref tabs index) focus)
                         (set! last-tab-focused index)
                         )
                       )
                     (define tab-elm
                       (new tab-panel%
                            [choices (for/list ([link self-links])
                                       (url->string link)
                                       )
                                     ]
                            [parent frame]
                            [callback 
                              (lambda (panel event)
                                (send (list-ref tabs last-tab-focused) unfocus)
                                (do-focus)
                                (update-title)
                                )
                              ]
                            )
                       )
                     (define/private (set-title title)
                       (send frame set-label (format "~a - ~a" title label))
                       )
                     (define (update-title)
                       (print-info "Updating title")
                       (let ([title (send (getCurrentTab) get-title)]
                             [currentNum (send tab-elm get-selection)]
                             )
                         (set-title title)
                         (send tab-elm set-item-label currentNum title)
                         )
                       )
                     (super-new)
                     ; Show frame before adding the tabs. It makes it a bit 
                     ; faster.
                     (send frame show #t) 
                     (set! tabs
                       (for/list ([tab-link self-links]) (makeTab tab-link))
                       )
                     (do-focus)
                     )
  )

