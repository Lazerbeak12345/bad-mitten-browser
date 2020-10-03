#lang typed/racket/base
(require typed/net/url typed/racket/class "../consoleFeedback.rkt")
(define-type Renderer% (Class (init [initial-URL URL]
                                    [parent Any]
                                    [setUrl! (-> URL Void)])
                              [navigate-to (-> URL Void)]))
(provide renderer% Renderer%)
(define renderer%
  (class object%
    (init [initial-URL : URL]
          [setUrl! : (-> URL Void)]
          [parent : Any])
    (define/public (navigate-to theUrl)
      (print-info (format "navite-to ~a" theUrl)))
    (super-new)))
