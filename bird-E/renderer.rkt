#lang typed/racket/base
(require typed/net/url
         typed/racket/class
         typed/racket/gui/base
         "../consoleFeedback.rkt"
         "../networking.rkt"
         "dom-elm.rkt"
         "renderer-type.rkt"
         "pasteboard-settings.rkt"
         "xexp-to-dom.rkt")
; Renderer% comes from "renderer-type.rkt" as many files reference that type
(provide renderer% Renderer%)
(define renderer% : Renderer%
  (class object%
    (init initial-URL setUrl! parent setTitle!)
    (define theUrl : URL initial-URL)
    (define init-setUrl! : (-> URL Void) setUrl!)
    (define init-setTitle! : (-> String Void) setTitle!)
    (define init-parent : (Instance Area-Container<%>) parent)
    (define pasteboard-instance : (Instance Pasteboard%)
      (pasteboard-div-lock (new pasteboard%)))
    ; This is to make getting coordinates easier
    (define/public (get-editor) pasteboard-instance)
    (define editor-canvas-instance : (Instance Editor-Canvas%)
      (new editor-canvas%
           [parent init-parent]
           [editor pasteboard-instance]
           [style '(no-vscroll no-hscroll)]
           [horizontal-inset 0]
           [vertical-inset 0]
           [vert-margin 0]
           [horiz-margin 0]))
    (define domTree : (Listof Dom-Elm-Child) null)
    (super-new)
    (define/public (set-document-title! title)
                   (init-setTitle! title))
    (define/public (navigate-to newUrl)
      (print-info (format "navigate-to ~a" newUrl))
      (send pasteboard-instance begin-edit-sequence #f)
      (send pasteboard-instance select-all)
      (send pasteboard-instance delete)
      ; TODO kill old tree
      ; TODO not all URL changes require fetching from the server
      (set! theUrl newUrl)
      (set! domTree (xexp->dom (list (makeInitTree theUrl init-setUrl!))
                               #:parent this))
      (for ([element domTree]
            ; It should always be a dom-elm
            #:when (element . is-a? . dom-elm%))
           ; Both return none
           #|(print-info (format "get-max-width ~a"
                               (send pasteboard-instance get-max-width)))
           (print-info (format "get-min-width ~a"
                               (send pasteboard-instance get-min-width)))|#
           ; Seems to always return really small numbers
           #|(print-info (format "get-extent ~a"
                               (let ([w : (Boxof Real) (box 0)]
                                     [h : (Boxof Real) (box 0)])
                                 (send pasteboard-instance get-extent w h)
                                 (list w h))))|#
           ; These both always seem to return 14
           #|(print-info (format "editor-canvas.get-width ~a"
                               (send editor-canvas-instance get-width)))
           (print-info
             (format "editor-canvas.get-size ~a"
                     (let-values ([(w h)
                                   (send editor-canvas-instance get-size)])
                       (list w h))))|#
           (send (cast element (Instance Dom-Elm%)) reposition-children
                 (send (send editor-canvas-instance get-top-level-window)
                       get-width)
                 0
                 (box (cons (cast 0 Real)
                            (cast 0 Real)))))
      (send pasteboard-instance end-edit-sequence))
    (navigate-to theUrl)))
