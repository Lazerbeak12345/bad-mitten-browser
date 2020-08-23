#lang typed/racket/base
(require typed/net/url
         typed/racket/class
         typed/racket/gui/base
         "pages.rkt" ; For the xexp type
         "consoleFeedback.rkt"
         "networking.rkt")
(provide renderer% Renderer%)
(: rendererCanvasCallback
   (-> Xexp (-> (Instance Canvas%) (Instance DC<%>) Void)))
(define ((rendererCanvasCallback tree) canvas dc)
  (print-info "Paint!"))
(define-type Renderer% (Class #:implements Canvas%
                              (init [getUrl (-> URL)]
                                    [setUrl! (-> URL Void)])))
(define renderer%
  (class canvas% 
    (init [getUrl : (-> URL)] [setUrl! : (-> URL Void)])
    (define self-getUrl : (-> URL) getUrl)
    (define self-setUrl! : (-> URL Void) setUrl!)
    (define initial-tree : Xexp (makeInitTree self-getUrl self-setUrl!))
    (super-new [paint-callback (rendererCanvasCallback initial-tree)])))
