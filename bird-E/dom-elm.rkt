#lang typed/racket/base
#|
This file is a part of the Bad-Mitten Browser and is a nontext domtree element
Copyright (C) 2021  Nathan Fritzler jointly with the Free Software Foundation

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
(provide dom-elm% Dom-Elm% Dom-Elm-Parent Dom-Elm-Child)
(require (only-in racket/string string-trim)
         (only-in typed/racket/class
                  class
                  define/public
                  define/private
                  init
                  init-field
                  is-a?
                  new
                  object%
                  send
                  super-new
                  this)
         (only-in typed/racket/gui/base
                  snip%
                  string-snip%
                  Editor<%>
                  Pasteboard%
                  Snip%
                  String-Snip%)
         (only-in "../consoleFeedback.rkt" print-error print-info print-warning)
         (only-in "../xexp-type.rkt" Xexp-attr)
         (only-in "box-bounding.rkt"
                  add-box-boundings 
                  box-bounding
                  box-bounding-h
                  box-bounding-too-right?
                  box-bounding-w
                  location
                  location-new-line 
                  location-nl/cr
                  location-return-left
                  location-x
                  location-y)
         (only-in "renderer-type.rkt" Display Renderer%)
         (only-in "snip-utils.rkt" get-snip-coordinates))
(define-type Dom-Elm-Parent (U (Instance Dom-Elm%)
                               (Instance Renderer%)))
(define-type Dom-Elm-Child (U (Instance Dom-Elm%)
                              (Instance String-Snip%)))
(define-type
  Dom-Elm% (Class (init [name Symbol]
                        [attrs (Listof Xexp-attr)]
                        [parent Dom-Elm-Parent]
                        [children ((Instance Dom-Elm%)
                                   -> (Listof Dom-Elm-Child))])
                  (init-field [editor (Instance Editor<%>)])
                  [reposition
                    (box-bounding box-bounding location Display
                                  -> (Values box-bounding Display))]
                  [set-document-title! (String -> Void)]
                  [get-count (-> Exact-Nonnegative-Integer)]
                  [get-name (-> Symbol)]
                  [get-snip (-> (Instance Snip%))]
                  [get-text
                    (->* (Exact-Nonnegative-Integer Exact-Nonnegative-Integer)
                         (Boolean)
                         String)]))
(define dom-elm% : Dom-Elm%
  (class
    object%
    (init name attrs parent children)
    (super-new)
    (define init-name : Symbol name) ; TODO make into field
    (define init-attrs : (Listof Xexp-attr) attrs)
    (define init-parent : Dom-Elm-Parent parent)
    (define init-children : (Listof Dom-Elm-Child) (children this))
    ; This is a temporary snip. Get rid of it and replace it with a proper snip
    ; of some sort at initialization
    (define snip : (Instance Snip%) (new string-snip%))
    (define/public (get-snip) snip)
    (define/public (get-name) init-name)
    (init-field editor)
    ; This is the xy position and the size that this element is occupying
    (define occupied : box-bounding (box-bounding 0 0 0 0))
    ; Should this element even render?
    (define display : Display 'block)
    (print-warning "TODO dom-elm.rkt more keyword args")
    (: place-dom-elm%-child :
       (Instance Dom-Elm%)
       box-bounding
       box-bounding
       location
       -> box-bounding)
    (define/private (place-dom-elm%-child element
                                          parent-min-size
                                          parent-max-size
                                          cursor)
                    (when (display . eq? . 'block)
                      (set! cursor (location-nl/cr cursor
                                                   occupied
                                                   0
                                                   parent-min-size)))
                    (define-values (child-bounding child-display)
                      (send element reposition
                            (box-bounding (location-x cursor)
                                          (location-y cursor)
                                          0
                                          0)
                            (box-bounding (location-x cursor)
                                          (location-y cursor)
                                          (box-bounding-w parent-max-size)
                                          (box-bounding-h parent-max-size))
                            cursor
                            display))
                    (when (display . eq? . 'block)
                      (set! cursor (location-nl/cr
                                     cursor
                                     occupied
                                     (box-bounding-h child-bounding)
                                     parent-min-size)))
                    child-bounding)
    (: place-string-snip%-child :
       (Instance String-Snip%)
       (Instance Pasteboard%)
       box-bounding
       box-bounding
       location
       -> box-bounding)
    (define/private (place-string-snip%-child element
                                              editor
                                              parent-min-size
                                              parent-max-size
                                              parent-cursor)
        (define-values (ex ey snip-width snip-height)
          (get-snip-coordinates editor element))
        (when (box-bounding-too-right?
                parent-max-size
                (box-bounding (location-x parent-cursor)
                              (location-y parent-cursor)
                              snip-width
                              snip-height))
          (set! parent-cursor
            (location-return-left parent-cursor parent-min-size))
          (set! parent-cursor
            (location-new-line parent-cursor occupied 0)))
        (send editor move-to element
              (location-x parent-cursor)
              (location-y parent-cursor))
        (define old-x (location-x parent-cursor))
        (set! parent-cursor
          (location (old-x . + . snip-width)
                    (location-y parent-cursor)))
        (box-bounding old-x
                      (location-y parent-cursor)
                      snip-width
                      snip-height))
    #|Reposition this element and its children|#
    (define/public
      (reposition parent-min-size parent-max-size parent-cursor parent-display)
      (define ed (cast editor (Instance Pasteboard%)))
      (set! occupied (box-bounding (location-x parent-cursor)
                                   (location-y parent-cursor)
                                   (box-bounding-w occupied)
                                   (box-bounding-h occupied)))
      (unless (display . eq? . 'none)
        (for ([element init-children])
             (define child-occupied
               (if (element . is-a? . dom-elm%)
                 (place-dom-elm%-child (cast element (Instance Dom-Elm%))
                                       parent-min-size
                                       parent-max-size
                                       parent-cursor)
                 (place-string-snip%-child
                   (cast element (Instance String-Snip%))
                   ed
                   parent-min-size
                   parent-max-size
                   parent-cursor)))
             (set! occupied (add-box-boundings occupied child-occupied))))
      (values occupied display))
    (define/public (set-document-title! title)
                   (send init-parent set-document-title! title))
    (define/public (get-count)
                   ; TODO does this need a fix?
                   (length init-children))
    (define/public (get-text a b [c #f])
                   (print-error "fix Dom-Elm% get-text")
                   (send snip get-text a b c))
    ; TODO define private vars for keeping track of box-sizing when needed
    (case init-name
      [(head script)
       (set! display 'none)
       (print-info (format "it's a ~a!" init-name))]
      [(title)
       (define title "")
       (for ([element init-children])
            ; TODO assert that it's a string snip
            (set! title
              (string-append
                title
                " "
                (send element get-text
                      0
                      (cast (send element get-count) Nonnegative-Integer)
                      #t))))
       (set-document-title! (string-trim title))]
      [else
        (when (memq init-name '(a i b bold em strong span))
          (set! display 'inline))
        (for ([element init-children])
             (send editor insert
                   (if (element . is-a? . snip%)
                       (cast element (Instance Snip%))
                       (send (cast element (Instance Dom-Elm%)) get-snip))))])))
