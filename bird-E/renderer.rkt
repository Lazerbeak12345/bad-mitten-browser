#lang typed/racket/base
#|
This file is a part of the Bad-Mitten Browser and is the root of a dom tree
Copyright (C) 2022  Nathan Fritzler jointly with the Free Software Foundation

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
(require (only-in typed/net/url URL)
         (only-in typed/racket/class class define/public init is-a? new object% send super-new this)
         (only-in typed/racket/gui/base
                  editor-canvas%
                  pasteboard%
                  Area-Container<%>
                  Editor-Canvas%
                  Pasteboard%)
         (only-in "../networking.rkt" makeInitTree)
         (only-in "box-bounding.rkt" box-bounding location)
         (only-in "dom-elm.rkt" dom-elm% Dom-Elm% Dom-Elm-Child)
         (only-in "renderer-type.rkt" Renderer%)
         (only-in "xexp-to-dom.rkt" xexp->dom))
; Renderer% comes from "renderer-type.rkt" as many files reference that type
(provide renderer%
         Renderer%)
(define renderer%
  :
  Renderer%
  (class object%
    (init initial-URL
          setUrl!
          parent
          setTitle!)
    (define theUrl
      :
      URL
      initial-URL)
    (define init-setUrl!
      :
      (URL -> Void)
      setUrl!)
    (define init-setTitle!
      :
      (String -> Void)
      setTitle!)
    (define init-parent
      :
      (Instance Area-Container<%>)
      parent)
    (define pasteboard-instance
      :
      (Instance Pasteboard%)
      (let ([pasteboard (new pasteboard%)])
        (send pasteboard set-dragable #f)
        pasteboard))
    (define editor-canvas-instance
      :
      (Instance Editor-Canvas%)
      (new editor-canvas%
           [parent init-parent]
           [editor pasteboard-instance]
           [style '(no-vscroll no-hscroll)]
           [horizontal-inset 0]
           [vertical-inset 0]
           [vert-margin 0]
           [horiz-margin 0]))
    (define domTree
      :
      (Listof Dom-Elm-Child)
      null)
    (super-new)
    (define/public (set-document-title! title) (init-setTitle! title))
    (define/public (navigate-to newUrl)
      (log-info "navigate-to ~a" newUrl)
      (send pasteboard-instance begin-edit-sequence #f)
      (send pasteboard-instance select-all)
      (send pasteboard-instance delete)
      ; TODO kill old tree
      ; TODO not all URL changes require fetching from the server
      (set! theUrl newUrl)
      (set! domTree
            (xexp->dom (list (makeInitTree theUrl init-setUrl!))
                       #:parent this
                       #:editor pasteboard-instance))
      (for ([element domTree]
            ; It should always be a dom-elm
            #:when (element . is-a? . dom-elm%))
        ; Both return none
        #|(log-info "get-max-width ~a"
                               (send pasteboard-instance get-max-width))
           (log-info "get-min-width ~a"
                               (send pasteboard-instance get-min-width))|#
        ; Seems to always return really small numbers
        #|(log-info "get-extent ~a"
                               (let ([w : (Boxof Real) (box 0)]
                                     [h : (Boxof Real) (box 0)])
                                 (send pasteboard-instance get-extent w h)
                                 (list w h)))|#
        ; These both always seem to return 14
        #|(log-info "editor-canvas.get-width ~a"
                               (send editor-canvas-instance get-width))
           (log-info
             (format "editor-canvas.get-size ~a"
                     (let-values ([(w h)
                                   (send editor-canvas-instance get-size)])
                       (list w h))))|#
        (define top-level-window (send editor-canvas-instance get-top-level-window))
        (define tw (send top-level-window get-width))
        (define th (send top-level-window get-height))
        (send (cast element (Instance Dom-Elm%))
              reposition
              (box-bounding 0 0 0 0)
              (box-bounding tw th tw th)
              (location 0 0)
              'block))
      (send pasteboard-instance end-edit-sequence))
    (navigate-to theUrl)))
