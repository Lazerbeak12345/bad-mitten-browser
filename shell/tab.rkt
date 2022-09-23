#lang typed/racket/base
#|
This file is a part of the Bad-Mitten Browser. It's the code for a single tab
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
(require (only-in racket/list first)
         (only-in typed/racket/gui/base panel% Button% Panel% Text-Field%)
         (only-in typed/racket/class
                  class
                  define/private
                  define/public
                  init
                  new
                  object?
                  object%
                  send
                  super-new)
         (only-in typed/net/url netscape/string->url url->string URL)
         (only-in "../bird-E/renderer.rkt" renderer% Renderer%))
(provide tab%
         Tab%)
(define-type Tab%
             (Class (init [url URL]
                          [locationBox (Instance Text-Field%)]
                          [locationBack (Instance Button%)]
                          [locationForward (Instance Button%)]
                          [tab-holder (Instance Panel%)]
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
(define tab%
  :
  Tab%
  (class object%
    (init url
          locationBox
          locationBack
          locationForward
          tab-holder
          update-title)
    (define self-url
      :
      URL
      url)
    (define ext-locationBox
      :
      (Instance Text-Field%)
      locationBox)
    (define ext-locationBack
      :
      (Instance Button%)
      locationBack)
    (define ext-locationForward
      :
      (Instance Button%)
      locationForward)
    (define ext-tab-holder
      :
      (Instance Panel%)
      tab-holder)
    (define ext-update-title
      :
      (-> Void)
      update-title)
    ; Should always be either the url as a string, or the html title
    (define title
      :
      String
      (url->string self-url))
    (define history
      :
      (Listof URL)
      '())
    (define history-future
      :
      (Listof URL)
      '())
    (define renderer
      :
      (U Null (Instance Renderer%))
      null)
    ;place for tab to be rendered upon
    (define thisPanel
      :
      (Instance Panel%)
      (new panel% [parent ext-tab-holder] [style '(deleted)]))
    (: initRenderer : -> Void)
    (define/private (initRenderer)
      (log-info (format "Starting renderer on ~a" (url->string self-url)))
      (clean)
      (unless (null? renderer)
        (error 'initRenderer "Can only be called once."))
      (set! renderer
            (new renderer%
                 [parent thisPanel]
                 [initial-URL self-url]
                 [setUrl!
                  (lambda (newUrl)
                    (set! self-url newUrl)
                    (clean))]
                 [setTitle!
                  (lambda (newTitle)
                    (set! title newTitle)
                    (ext-update-title))])))
    (: navigate-to : URL -> Void)
    (define/private (navigate-to the-url)
      (log-info (format "Navigating to '~a'" title))
      (set! self-url the-url)
      (clean)
      (send (assert renderer object?) navigate-to the-url))
    (: updateLocationButtons : -> Void)
    (define/private (updateLocationButtons)
      (log-info "Updating location buttons")
      (send ext-locationBack enable (not (null? history)))
      (send ext-locationForward enable (not (null? history-future))))
    (: clean : -> Void)
    (define/private (clean)
      (log-info "Cleaning…")
      (set! title (url->string self-url))
      (ext-update-title)
      ; We don't actually need to empty this anymore.
      ;(send thisPanel change-children (lambda (current) '()))
      ; TODO wipe current canvas?
      (updateLocationButtons))
    (super-new)
    (define/public (close)
      (log-info (format "Closing ~a" (url->string self-url)))
      (log-error "tab.rkt tab close not written yet?"))
    ; usually called when the address box is modified
    (define/public (locationChanged)
      (define new-url (netscape/string->url (send ext-locationBox get-value)))
      (if (equal? self-url new-url)
          (log-warning "Url value didn't change")
          (let ([self-url-string (url->string self-url)] [new-url-string (url->string new-url)])
            (log-info (format "Changing '~a' to '~a'" self-url-string new-url-string))
            (send ext-locationBox set-value new-url-string)
            (set! history (cons self-url history))
            (set! history-future '())
            (navigate-to new-url))))
    (define/public (focus)
      (log-info (format "Focusing '~a'" (url->string self-url)))
      (when (null? renderer)
        (initRenderer))
      (send ext-locationBox set-value (url->string self-url))
      (send ext-tab-holder add-child thisPanel)
      (updateLocationButtons))
    (define/public (unfocus)
      (log-info (format "Unfocusing '~a'" (url->string self-url)))
      (send ext-tab-holder delete-child thisPanel))
    (define/public (reload)
      (log-info (format "Reloading '~a'" (url->string self-url)))
      (navigate-to self-url))
    (define/public (back)
      (log-info (format "Going back on '~a'" (url->string self-url)))
      (let* ([new-url (first history)] [new-url-string (url->string new-url)])
        (send ext-locationBox set-value new-url-string)
        (set! history (cdr history))
        (set! history-future (cons self-url history-future))
        (navigate-to new-url)))
    (define/public (forward)
      (log-info (format "Going forward on '~a'" (url->string self-url)))
      (let* ([new-url (first history-future)] [new-url-string (url->string new-url)])
        (send ext-locationBox set-value new-url-string)
        (set! history (cons self-url history))
        (set! history-future (cdr history-future))
        (navigate-to new-url)))
    (define/public (get-title) title)
    (define/public (get-url) self-url)))
