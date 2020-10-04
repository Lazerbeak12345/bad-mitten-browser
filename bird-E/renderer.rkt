#lang typed/racket/base
(require typed/net/url
         typed/racket/class
         typed/racket/gui/base
         "../consoleFeedback.rkt")
(define-type Renderer% (Class #:implements/inits Editor-Canvas%
                              (init [initial-URL URL]
                                    [setUrl! (-> URL Void)])
                              [navigate-to (-> URL Void)]))
(provide renderer% Renderer%)
(define renderer% : Renderer%
  (class editor-canvas%
    (init initial-URL setUrl!)
    (define/public (navigate-to theUrl)
      (print-info (format "navigate-to ~a" theUrl)))
    (init-rest)
    (super-new)))
