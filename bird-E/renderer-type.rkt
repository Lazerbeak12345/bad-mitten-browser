#lang typed/racket/base
(require typed/net/url
         typed/racket/class
         typed/racket/gui/base)
(provide Renderer%)
(define-type Renderer% (Class (init [initial-URL URL]
                                    [setUrl! (-> URL Void)]
                                    [parent (Instance Area-Container<%>)])
                              [navigate-to (-> URL Void)]
                              [get-editor (-> (Instance Editor<%>))]))

