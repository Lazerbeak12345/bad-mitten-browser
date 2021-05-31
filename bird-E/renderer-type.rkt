#lang typed/racket/base
(require typed/net/url typed/racket/class typed/racket/gui/base)
(provide Renderer%)
(define-type Renderer% (Class (init [initial-URL URL]
                                    [setUrl! (URL -> Void)]
                                    [parent (Instance Area-Container<%>)]
                                    [setTitle! (String -> Void)])
                              [navigate-to (URL -> Void)]
                              [get-editor (-> (Instance Editor<%>))]
                              [set-document-title! (String -> Void)]))
(struct box-bounding ([x : Real]
                      [y : Real]
                      [w : Real]
                      [h : Real]) #:mutable)
(provide box-bounding box-bounding? box-bounding-x box-bounding-y
         box-bounding-w box-bounding-h set-box-bounding-x! set-box-bounding-y!
         set-box-bounding-w! set-box-bounding-h!)
(struct location ([x : Real]
                  [y : Real]) #:mutable)
(provide location location? location-x location-y set-location-x!
         set-location-y!)
(define-type Display (U 'block 'inline 'none))
(provide Display)
