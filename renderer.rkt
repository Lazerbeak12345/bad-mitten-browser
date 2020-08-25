#lang typed/racket/base
(require typed/net/url
         typed/racket/class
         typed/racket/draw
         typed/racket/gui/base
         "consoleFeedback.rkt"
         "bird-E/dom-root.rkt"
         "networking.rkt")
(provide renderer% Renderer%)
(define-type Renderer% (Class #:implements Canvas%
                              (init [initial-Url URL]
                                    [setUrl! (-> URL Void)])
                              [navigate-to (-> URL Void)]))
(define renderer%
  (class canvas% 
    (init [initial-URL : URL] [setUrl! : (-> URL Void)])
    (define ext-setUrl! : (-> URL Void) setUrl!)
    (: initDom (-> URL (Instance Dom-Root-Node%)))
    (define/private (initDom theUrl)
      (new dom-root-node%
           [initial-tree (makeInitTree theUrl ext-setUrl!)]))
    (define dom : (Instance Dom-Root-Node%) (initDom initial-URL))
    (: navigate-to (-> URL Void))
    (define/public (navigate-to newUrl)
      (send (send this get-dc) clear)
      ; TODO drop dom nicely
      ; TODO initDom uses ext-getUrl to get the latest url... I don't really
      ; like that anymore...
      (set! dom (initDom newUrl)))
    (super-new
      [paint-callback (lambda (canvas dc)
                        ; contact the dom for the image and render it
                        (print-info "Paint!"))])))
