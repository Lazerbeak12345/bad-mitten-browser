#lang typed/racket/base
; The code for a single browser tab
(require typed/racket/gui/base
         typed/racket/class
         racket/list ; Require typed later?
         typed/net/url
         "consoleFeedback.rkt"
         "renderer.rkt")
(provide tab% Tab%)
(define-type Tab% 
  (Class (init [url URL]
               [locationBox (Instance Text-Field%)]
               [locationBack (Instance Button%)]
               [locationForward (Instance Button%)]
               [tab-panel (Instance Tab-Panel%)]
               [update-title (-> Void)])
         [close (-> Void)]
         [locationChanged (-> Void)]
         [focus (-> Void)]
         [unfocus (-> Void)]
         [reload (-> Void)]
         [back (-> Void)]
         [forward (-> Void)]
         [get-title (-> String)]
         [get-url (-> URL)]))
(define tab% : Tab%
  (class object%
    (init [url : URL]
          [locationBox : (Instance Text-Field%)]
          [locationBack : (Instance Button%)]
          [locationForward : (Instance Button%)]
          [tab-panel : (Instance Tab-Panel%)]
          [update-title : (-> Void)])
    (define self-url : URL url)
    (define ext-locationBox : (Instance Text-Field%) locationBox)
    (define ext-locationBack : (Instance Button%) locationBack)
    (define ext-locationForward : (Instance Button%) locationForward)
    (define ext-tab-panel : (Instance Tab-Panel%) tab-panel)
    (define ext-update-title : (-> Void) update-title)
    ; Should always be either the url as a string, or the html title
    (define title : String (url->string self-url))
    (define history : (Listof URL) '())
    (define history-future : (Listof URL) '())
    (define canvas : (U Null (Instance Canvas%)) null)
    ;place for tab to be rendered upon
    (define thisPanel : (Instance Panel%)
      (new panel% [parent ext-tab-panel] [style '(deleted)]))
    (: initRenderer (-> Void))
    (define/private (initRenderer)
      (print-info (format "Starting renderer on ~a" (url->string self-url)))
      (clean)
      (unless (null? canvas)
        (error 'initRenderer "Can only be called once."))
      (set! canvas (make-canvas thisPanel)))
    (: navigate-to (-> URL Void))
    (define/private (navigate-to the-url)
      (set! title (url->string the-url))
      (print-info (format "Navigating to '~a'" title))
      (set! self-url the-url)
      (clean))
    (: updateLocationButtons (-> Void))
    (define/private (updateLocationButtons)
      (print-info "Updating location buttons")
      (send ext-locationBack enable (not (null? history)))
      (send ext-locationForward enable (not (null? history-future))))
    (: clean (-> Void))
    (define/private (clean)
      (print-info "Cleaning…")
      (set! title (url->string self-url))
      (ext-update-title)
      (send thisPanel change-children (lambda (current) '()))
      (updateLocationButtons))
    (super-new)
    (: close (-> Void))
    (define/public (close)
      (print-info (format "Closing ~a" (url->string self-url)))
      (print-error "tab.rkt tab close not written yet?"))
    (: locationChanged (-> Void))
    (define/public (locationChanged)
      (define new-url (netscape/string->url (send ext-locationBox get-value)))
      (if (equal? self-url new-url)
        (print-warning "Url value didn't change")
        (let ([self-url-string (url->string self-url)]
              [new-url-string (url->string new-url)])
          (print-info (format "Changing '~a' to '~a'"
                              self-url-string
                              new-url-string))
          (send ext-locationBox set-value new-url-string)
          (set! history (cons self-url history))
          (set! history-future '())
          (navigate-to new-url))))
    (: focus (-> Void))
    (define/public (focus)
      (print-info (format "Focusing '~a'" (url->string self-url)))
      (when (null? canvas)
        (initRenderer))
      (send ext-locationBox set-value (url->string self-url))
      (send ext-tab-panel add-child thisPanel)
      (updateLocationButtons))
    (: unfocus (-> Void))
    (define/public (unfocus)
      (print-info (format "Unfocusing '~a'" (url->string self-url)))
      (send ext-tab-panel delete-child thisPanel))
    (: reload (-> Void))
    (define/public (reload)
      (print-info (format "Reloading '~a'" (url->string self-url)))
      (navigate-to self-url))
    (: back (-> Void))
    (define/public (back)
      (print-info (format "Going back on '~a'" (url->string self-url)))
      (let* ([new-url (first history)]
             [new-url-string (url->string new-url)])
        (send ext-locationBox set-value new-url-string)
        (set! history (cdr history))
        (set! history-future (cons self-url history-future))
        (navigate-to new-url)))
    (: forward (-> Void))
    (define/public (forward)
      (print-info (format "Going forward on '~a'" (url->string self-url)))
      (let* ([new-url (first history-future)]
             [new-url-string (url->string new-url)])
        (send ext-locationBox set-value new-url-string)
        (set! history (cons self-url history))
        (set! history-future (cdr history-future))
        (navigate-to new-url)))
    (: get-title (-> String))
    (define/public (get-title) title)
    (: get-url (-> URL))
    (define/public (get-url) self-url)))
