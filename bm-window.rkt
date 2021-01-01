#lang typed/racket/base
; The main window

; NOTE: I am specifically targeting the GNOME desktop enviroment, and plan to
; follow their official appearance guidelines in the future.
(require typed/images/icons
         typed/net/url
         typed/pict
         typed/racket/class
         typed/racket/gui/base
         "consoleFeedback.rkt"
         "tab.rkt") 
(provide bm-window% Bm-window%)
#| Use a unicode character as an icon |#
(: char->icon (-> String (Instance Bitmap%)))
(define (char->icon char)
  (text-icon char
             ; TODO fix upstream to allow 'heavy and numbers
             (make-font #:weight 'bold)
             #:color metal-icon-color
             #:trim? #t))
(define-type Bm-window%
             (Class (init [links (U Null
                                    String
                                    (Listof String)
                                    URL
                                    (Listof URL))])))
#| An instance of this browser's window |#
(define bm-window% : Bm-window%
  (class object% (init links)
    (define self-links : (Listof URL)
      (let ([_links links]) ; Only initialize links once
        (cond [(null? _links)
               (list (netscape/string->url "bm:newtab"))]
              ; TODO use listof contract instead of these ugly things
              [(and (list? _links)
                    (string? (car _links)))
               (for/list [(link _links)]
                 (netscape/string->url link))]
              ; see above TODO
              [(and (list? _links)
                    (url? (car _links)))
               _links]
              [(url? _links)
               (list _links)]
              [(string? _links)
               (list (netscape/string->url _links))])))
    (define label : String "Bad-Mitten Browser")
    (define frame : (Instance Frame%)
      (let-values ([(width height)
                    (get-display-size)])
        (new frame%
             [label label]
             ; I just guessed these numbers. Works for gnome, works for me
             [width 800]
             [height 600]
             ; lol I guess I'll have to figure out this dyamic stuff later:
             ; it won't compile for typing reasons
             #|[width (if (number? width)
                      (ceiling (width . * . .7))
                      800)]
             [height (if (number? height)
                       (ceiling (height . / . 1.5))
                       600)]|#
             [alignment '(center top)])))
    ; TODO set-icon (doesn't work on KDE Plasma 5.18.5 (wayland) or on GNOME
    ; 3.16.5 (wayland), but does work on KDE (same version) (X11))
    #|(send frame set-icon
          (pict->bitmap
            (disk ((default-icon-height) . * . (2 . / . 3))
                  #:color "white"
                  #:border-color "lightgrey"
                  #:border-width ((default-icon-height) . / .  8))))|#
    #|(send frame set-icon (let* ([h (* 10 (default-icon-height))]
                                [dc (new bitmap-dc%
                                         [bitmap (make-bitmap (ceiling h)
                                                              (ceiling h))])]
                               [pen-width (h . / . 8)])
                           (send dc set-pen (new pen%
                                                 [color "grey"]
                                                 [width pen-width]))
                           (send dc draw-line 0 h (h . * . .6) (h . * . .4))
                           (send dc
                                 draw-ellipse
                                 (h . * . .25)
                                 (h . * . .3)
                                 (h . * . .5)
                                 (h . * . .5))
                           (or (send dc get-bitmap)
                               (make-object bitmap%
                                            (ceiling h)
                                            (ceiling h)))))|#
    (define locationPane : (Instance Horizontal-Pane%)
      (new horizontal-pane% 
           ; TODO text align vert-center
           [parent frame]
           [alignment '(left center)]))
    (send locationPane stretchable-height #f)
    (: locationChanged ((Instance Text-Field%)
                        (Instance Control-Event%)
                        . -> .
                        Void))
    (define (locationChanged pane event)
      (when (eq? (send event get-event-type)
                 'text-field-enter)
        (print-info "Location changed!")
        ; They already have access to the url box
        (send (getCurrentTab) locationChanged)))
    (define addTabBtn : (Instance Button%)
      (new button%
           [parent locationPane]
           ;[label "New Tab"]
           [label (char->icon "+")]
           [callback (lambda (button event)
                       (addTabBtnCallback))]))
    (define locationBack : (Instance Button%)
      (new button%
           [parent locationPane]
           ;[label "Back"]
           [label (back-icon #:color metal-icon-color)]
           [callback (lambda (button event)
                       (send (getCurrentTab) back))]))
    (define locationForward : (Instance Button%)
      (new button%
           [parent locationPane]
           ;[label "Forward"]
           [label (play-icon #:color metal-icon-color)]
           [callback (lambda (button event)
                       (send (getCurrentTab) forward))]))
    (define locationReload : (Instance Button%)
      (new button%
           [parent locationPane]
           ;[label "Reload"]
           [label (char->icon "⟳")]
           [callback (lambda (button event)
                       (send (getCurrentTab) reload))]))
    ; The location box. I would prefer if this were in the top bar instead.
    (define locationBox : (Instance Text-Field%)
      (new text-field%
           [parent locationPane]
           ;[label "URL:"]
           [label ""]
           [callback locationChanged]))
    (send locationBox stretchable-height #t)
    (define tabManagerPanel : (Instance Horizontal-Panel%)
      (new horizontal-panel% [parent frame] [alignment '(right center)]))
    (send tabManagerPanel stretchable-height #f)
    (define tab-elm : (Instance Tab-Panel%)
      (new tab-panel%
           [choices (for/list ([link self-links])
                      (url->string link))]
           [parent tabManagerPanel]
           [style '(no-border)]
           [callback (lambda (panel event)
                       (send (list-ref tabs last-tab-focused) unfocus)
                       (do-focus)
                       (update-title))]))
    (send tab-elm stretchable-height #f)
    (define tab-holder : (Instance Panel%)
      (new panel% [parent frame]))
    (: makeTab (-> URL (Instance Tab%)))
    (define/private (makeTab tab-link)
      (new tab%
           [url tab-link]
           [locationBox locationBox]
           [locationBack locationBack]
           [locationForward locationForward]
           [tab-holder tab-holder]
           [update-title update-title]))
    (: get-tab-choices (-> (Listof String)))
    (define/private (get-tab-choices)
      (for/list ([tab tabs])
        (send tab get-title)))
    ; Called to either hide or show the tab row
    (: hideTabRow (-> Boolean Void))
    (define/private (hideTabRow bool)
      (print-info (format "hideTabRow ~a" bool))
      (if bool
        (send frame delete-child tabManagerPanel)
        (begin 
          (send frame delete-child tab-holder)
          (send frame add-child tabManagerPanel)
          (send frame add-child tab-holder))))
    (: addTabBtnCallback (-> Void))
    (define/private (addTabBtnCallback)
      (print-info "Making new tab")
      (send (getCurrentTab) unfocus)
      (when (= 1 (length tabs))
        (hideTabRow #f))
      (set! tabs
        (append tabs (list (makeTab (netscape/string->url "bm:newtab"))))) 
      (send tab-elm set (get-tab-choices))
      (send tab-elm set-selection (- (length tabs) 1))
      (do-focus))
    (: closeCurrentTab (-> Void))
    (define/private (closeCurrentTab)
      (let ([current (getCurrentTab)]) 
        (print-info (format "Closing ~a" (send current get-title)))
        (send current unfocus))
      (define counter -1)
      (define index ((send tab-elm get-selection) . or . 0))
      (send (list-ref tabs index) close)
      (set! tabs (filter (lambda (item)
                           (set! counter (+ counter 1))
                           (not (= counter index)))
                         tabs))
      (send tab-elm set (get-tab-choices))
      (if (= 0 (length tabs))
        (begin
          (print-info "Closing browser!")
          (exit 0))
        (begin
          (send tab-elm set-selection (if (= 0 index)
                                        0
                                        (- index 1)))
          (when (= 1 (length tabs))
            (hideTabRow #t))))
      (do-focus))
    (define closeTabBtn : (Instance Button%)
      (new button%
           [parent tabManagerPanel]
           ;[label "Close Tab"]
           [label (x-icon #:color metal-icon-color
                          ; TODO increase later
                          #:thickness 6)]
           [callback (lambda (button event)
                       (closeCurrentTab))]))
    (let-values ([(width height) (send closeTabBtn get-graphical-min-size)])
      ; (print-info (~a width))
      (send locationBack min-width width)
      (send locationForward min-width width)
      (send locationReload min-width width)
      (send addTabBtn min-width width)
      (send closeTabBtn min-width width))
    (define last-tab-focused 0)
    (define tabs : (Listof (Instance Tab%)) null)
    (: getCurrentTab (-> (Instance Tab%)))
    (define/private (getCurrentTab)
      (print-info "Getting current tab")
      (list-ref tabs ((send tab-elm get-selection) . or . 0)))
    (: do-focus (-> Void))
    (define/private (do-focus)
      (let ([index : Integer ((send tab-elm get-selection) . or . 0)])
        (send (list-ref tabs index) focus)
        (set! last-tab-focused index))
      (update-title))
    (: set-title (-> String Void))
    (define/private (set-title title)
      (send frame set-label (format "~a - ~a" title label)))
    (: update-title (-> Void))
    (define (update-title)
      (print-info "Updating title")
      (let ([title (send (getCurrentTab) get-title)]
            [currentNum : Integer ((send tab-elm get-selection) . or . 0)])
        (set-title title)
        (send tab-elm set-item-label currentNum title)))
    (super-new)
    ; Show frame before adding the tabs. It makes it a bit faster.
    (send frame show #t) 
    (set! tabs (for/list : (Listof (Instance Tab%)) ([tab-link self-links])
                 (makeTab tab-link)))
    (when (= 1 (length tabs))
      (hideTabRow #t))
    (do-focus)))

