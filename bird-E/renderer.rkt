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
    (define domTree : Any null) ; TODO better type
    (super-new)
    (define/public (navigate-to newUrl)
      (print-info (format "navigate-to ~a" newUrl))
      ; TODO kill old tree
      ; TODO not all URL changes require fetching from the server
      (set! theUrl newUrl)
      ; TODO is a single-item list used like this a code smell?
      (set! domTree (xexp->dom (list (makeInitTree theUrl init-setUrl!)))))
    (navigate-to theUrl))) 

