#lang typed/racket/base
(require typed/net/url
         typed/racket/class
         typed/racket/gui/base
         "../consoleFeedback.rkt")
(define-type Renderer% (Class (init [initial-URL URL]
                                    [setUrl! (-> URL Void)]
                                    [parent (Instance Area-Container<%>)])
                              [navigate-to (-> URL Void)]))
(provide renderer% Renderer%)
(define renderer% : Renderer%
  (class object%
    (init initial-URL setUrl! parent)
    (define theUrl : URL initial-URL)
    (define init-setUrl! : (-> URL Void) setUrl!)
    (define init-parent : (Instance Area-Container<%>) parent)
    (define editor-canvas-instance : (Instance Editor-Canvas%)
      (new editor-canvas%
           [parent init-parent]
           [style '(auto-vscroll auto-hscroll)]))
    (super-new)
    (define/public (navigate-to theUrl)
      (print-info (format "navigate-to ~a" theUrl))))) 

