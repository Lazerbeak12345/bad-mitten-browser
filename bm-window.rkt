#lang typed/racket/base
#|
This file is a part of the Bad-Mitten Browser and is the main window
Copyright (C) 2022 Lazerbeak12345 jointly with the Free Software Foundation

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
|#

; NOTE: I am specifically targeting the GNOME desktop enviroment, and plan to
; follow their official appearance guidelines in the future.
(require (only-in racket/math exact-ceiling)
         (only-in typed/images/icons
                  back-icon
                  metal-icon-color
                  play-icon
                  text-icon
                  x-icon)
         (only-in typed/net/url netscape/string->url url? url->string URL)
         ;typed/pict
         (only-in typed/racket/class
                  class
                  define/private
                  init
                  new
                  object%
                  send
                  super-new)
         (only-in typed/racket/gui/base
                  button%
                  frame%
                  get-display-size
                  horizontal-pane%
                  horizontal-panel%
                  make-font
                  panel%
                  text-field%
                  Bitmap%
                  Button%
                  Frame%
                  Horizontal-Pane%
                  Horizontal-Panel%
                  Panel%
                  Text-Field%
                  Control-Event%)
         (only-in "consoleFeedback.rkt" print-info)
         (only-in "custom-tab-panel.rkt"
                  tab-panel-closable%
                  Tab-Panel-Closable%)
         (only-in "tab.rkt" tab% Tab%))
(provide bm-window% Bm-window%)
(: clamp : Real Real Real -> Real)
(define (clamp start end value)
  (max (min value end) start))
#| Use a unicode character as an icon |#
(: char->icon : String -> (Instance Bitmap%))
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
              [((list? _links) . and . (string? (car _links)))
               (for/list [(link _links)]
                 (netscape/string->url link))]
              ; see above TODO
              [((list? _links) . and . (url? (car _links))) _links]
              [(url? _links)
               (list _links)]
              [(string? _links)
               (list (netscape/string->url _links))])))
    (define label : String "Bad-Mitten Browser")
    (define frame : (Instance Frame%)
      (let-values ([(width height)
                    (get-display-size)])
        (print-info (format "w&h ~a ~a" width height))
        (define scaleWindow (; those squareish ones
                             (height width . and . (height . < . width))
                             . or .
                             ; 4k should be scaled too
                             (height . and . (height . > . 1500))))
        (unless scaleWindow (print-info "Scaling initial window size!"))
        (new frame%
             [label label]
             ; I just guessed these numbers. Works for gnome, works for me
             ;[width 800]
             ;[height 600]
             ; lol I guess I'll have to figure out this dyamic stuff later:
             ; it won't compile for typing reasons
             [width (if (width . and . scaleWindow)
                      (exact-ceiling (width . * . .585651537))
                      800)]
             [height (if (height . and . scaleWindow)
                       (exact-ceiling (height . * . .78125))
                       600)]
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
    ; A callback for when the user changes the location
    (: locationChanged :
       (Instance Text-Field%)
       (Instance Control-Event%) -> Void)
    (define (locationChanged pane event)
      (when ((send event get-event-type) . eq? . 'text-field-enter)
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
      (new horizontal-panel%
           [parent frame]
           [alignment '(right center)]))
    (send tabManagerPanel stretchable-height #f)
    (define tab-elm : (Instance Tab-Panel-Closable%)
      (new tab-panel-closable%
           [choices (for/list ([link self-links])
                      (url->string link))]
           [parent tabManagerPanel]
           [style '(no-border can-close)]
           [on-close-request-callback (lambda (index)
                                        ; Can't indirectly apply class methods
                                        ; so a lambda is needed here
                                        (closeGivenTab index))]
           [callback (lambda (panel event)
                       (send (list-ref tabs last-tab-focused) unfocus)
                       (do-focus)
                       (update-title))]))
    (send tab-elm stretchable-height #f)
    (define tab-holder : (Instance Panel%)
      (new panel% [parent frame]))
    (: makeTab : URL -> (Instance Tab%))
    (define/private (makeTab tab-link)
      (new tab%
           [url tab-link]
           [locationBox locationBox]
           [locationBack locationBack]
           [locationForward locationForward]
           [tab-holder tab-holder]
           [update-title update-title]))
    (: get-tab-choices : -> (Listof String))
    (define/private (get-tab-choices)
      (for/list ([tab tabs])
        (send tab get-title)))
    ; Called to either hide or show the tab row
    (: hideTabRow : Boolean -> Void)
    (define/private (hideTabRow bool)
      (print-info (format "hideTabRow ~a" bool))
      (if bool
        (send frame delete-child tabManagerPanel)
        (begin 
          (send frame delete-child tab-holder)
          (send frame add-child tabManagerPanel)
          (send frame add-child tab-holder))))
    (: addTabBtnCallback : -> Void)
    (define/private (addTabBtnCallback)
      (print-info "Making new tab")
      (send (getCurrentTab) unfocus)
      (when ((length tabs) . = . 1)
        (hideTabRow #f))
      (set! tabs
        (append tabs (list (makeTab (netscape/string->url "bm:newtab"))))) 
      (send tab-elm set (get-tab-choices))
      (send tab-elm set-selection ((length tabs) . - . 1))
      (do-focus))
    (: closeCurrentTab : -> Void)
    (define/private (closeCurrentTab)
      (define index ((send tab-elm get-selection) . or . 0))
      (closeGivenTab index)
      (do-focus))
    (: closeGivenTab : Natural -> Void)
    (define/private (closeGivenTab index)
      (define current-focused ((send tab-elm get-selection) . or . 0))
      (define focused-left-of-close (current-focused . > . index))
      (send (list-ref tabs last-tab-focused) unfocus)
      (let ([index-tab (list-ref tabs index)])
        (print-info (format "Closing ~a at index ~a"
                            (send index-tab get-title)
                            index))
        (send index-tab close))
      (let ([counter -1])
        (set! tabs (filter (lambda (item)
                             (set! counter (counter . + . 1))
                             (not (counter . = . index)))
                           tabs)))
      (send tab-elm set (get-tab-choices))
      (send tab-elm set-selection (cast (clamp 0
                                               ((length tabs) . - . 1)
                                               (if focused-left-of-close
                                                 (current-focused . - . 1)
                                                 current-focused))
                                        Integer))
      (when ((length tabs) . = . 1)
             (hideTabRow #t))
      (do-focus))
    (let-values ([(width height) (send addTabBtn get-graphical-min-size)])
      ; (print-info (~a width))
      (send locationBack    min-width width)
      (send locationForward min-width width)
      (send locationReload  min-width width)
      (send addTabBtn       min-width width))
    (define last-tab-focused 0)
    (define tabs : (Listof (Instance Tab%)) null)
    (: getCurrentTab : -> (Instance Tab%))
    (define/private (getCurrentTab)
      (print-info "Getting current tab")
      (list-ref tabs ((send tab-elm get-selection) . or . 0)))
    (: do-focus : -> Void)
    (define/private (do-focus)
      (let ([index : Integer ((send tab-elm get-selection) . or . 0)])
        (send (list-ref tabs index) focus)
        (set! last-tab-focused index))
      (update-title))
    (: set-title : String -> Void)
    (define/private (set-title title)
      (send frame set-label (format "~a - ~a" title label)))
    (: update-title : -> Void)
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
    (when ((length tabs) . = . 1)
      (hideTabRow #t))
    (do-focus)))
