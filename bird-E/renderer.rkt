#lang typed/racket/base
(require typed/net/url
         typed/racket/class
         typed/racket/gui/base
         "../consoleFeedback.rkt"
         "../networking.rkt"
         "xexp-to-dom.rkt")
(provide renderer% Renderer%)
(define-type Renderer% (Class (init [initial-URL URL]
                                    [setUrl! (-> URL Void)]
                                    [parent (Instance Area-Container<%>)])
                              [navigate-to (-> URL Void)]))
(define renderer% : Renderer%
  (class object%
    (init initial-URL setUrl! parent)
    (define theUrl : URL initial-URL)
    (define init-setUrl! : (-> URL Void) setUrl!)
    (define init-parent : (Instance Area-Container<%>) parent)
    (define pasteboard-instance : (Instance Pasteboard%)
      (new pasteboard%))
    (define editor-canvas-instance : (Instance Editor-Canvas%)
      (new editor-canvas%
           [parent init-parent]
           [editor pasteboard-instance]
           [style '(auto-vscroll auto-hscroll)]))
    (define domTree : (Listof (Instance Snip%)) null)
    (super-new)
    (define/public (navigate-to newUrl)
      (print-info (format "navigate-to ~a" newUrl))
      (send pasteboard-instance select-all)
      (send pasteboard-instance delete)
      ; TODO kill old tree
      ; TODO not all URL changes require fetching from the server
      (set! theUrl newUrl)
      (set! domTree (xexp->dom (list (makeInitTree theUrl init-setUrl!))))
      ; TODO make this generic and use it in dom-elm as well
      (for ([element domTree])
        (print-info (format "element: ~a" element))
        (send pasteboard-instance insert element)))
    (navigate-to theUrl)))

