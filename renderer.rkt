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
                              (init [getUrl (-> URL)]
                                    [setUrl! (-> URL Void)])
                              [navigate-to (-> URL Void)]))
(define renderer%
  (class canvas% 
    (init [getUrl : (-> URL)] [setUrl! : (-> URL Void)])
    (define ext-getUrl : (-> URL) getUrl)
    (define ext-setUrl! : (-> URL Void) setUrl!)
    (: initDom (-> (Instance Dom-Root-Node%)))
    (define/private (initDom)
      (new dom-root-node%
           [initial-tree (makeInitTree ext-getUrl ext-setUrl!)]))
    (define dom : (Instance Dom-Root-Node%) (initDom))
    (: navigate-to (-> URL Void))
    (define/public (navigate-to new-url)
      (send (send this get-dc) clear)
      ; TODO drop dom nicely
      ; TODO initDom uses ext-getUrl to get the latest url... I don't really
      ; like that anymore...
      (set! dom (initDom)))
    (super-new
      [paint-callback (lambda (canvas dc)
                        ; contact the dom for the image and render it
                        (print-info "Paint!"))])))
