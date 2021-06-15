#lang typed/racket/base
(require typed/net/url
         typed/racket/class
         typed/racket/gui/base
         "box-bounding.rkt")
(provide (all-from-out "box-bounding.rkt"))
(provide Renderer%)
(define-type Renderer% (Class (init [initial-URL URL]
                                    [setUrl! (URL -> Void)]
                                    [parent (Instance Area-Container<%>)]
                                    [setTitle! (String -> Void)])
                              [navigate-to (URL -> Void)]
                              [get-editor (-> (Instance Editor<%>))]
                              [set-document-title! (String -> Void)]))
(define-type Display (U 'block 'inline 'none))
(provide Display)
