#lang typed/racket/base
(require typed/net/url
         typed/racket/class
         typed/racket/gui/base
         "consoleFeedback.rkt"
         "bird-E/dom-root.rkt"
         "networking.rkt")
(provide renderer% Renderer%)
(define-type Renderer% (Class #:implements Canvas%
                              (init [getUrl (-> URL)]
                                    [setUrl! (-> URL Void)])))
(define renderer%
  (class canvas% 
    (init [getUrl : (-> URL)] [setUrl! : (-> URL Void)])
    (define self-getUrl : (-> URL) getUrl)
    (define self-setUrl! : (-> URL Void) setUrl!)
    (define dom : (Instance Dom-Root-Node%)
      (new dom-root-node%
           [initial-tree (makeInitTree self-getUrl self-setUrl!)]))
    (super-new
      [paint-callback (lambda(canvas dc)
                        ; contact the dom for the image and render it
                        (print-info "Paint!"))])))
