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
    (init initial-URL setUrl! parent)
    (define theUrl : URL initial-URL)
    (define init-setUrl! : (-> URL Void) setUrl!)
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
    (define domTree : (Listof (U (Instance Dom-Elm%)
                                 (Instance String-Snip%))) null)
    (super-new)
    (define/public (navigate-to newUrl)
      (print-info (format "navigate-to ~a" newUrl))
      (send pasteboard-instance select-all)
      (send pasteboard-instance delete)
      ; TODO kill old tree
      ; TODO not all URL changes require fetching from the server
      (set! theUrl newUrl)
      (set! domTree (xexp->dom (list (makeInitTree theUrl init-setUrl!))
                               #:parent this))
      ; TODO make this generic and use it in dom-elm as well
      (for ([element domTree])
        (print-info (format "element: ~a" element))
        (send pasteboard-instance insert element 0 0)
        (when (element . is-a? . dom-elm%)
          (send (cast element (Instance Dom-Elm%)) reposition-children))))
    (navigate-to theUrl)))

