#lang racket
(require net/url
         net/url-connect
         net/head
         html-parsing
         "consoleFeedback.rkt"
         "pages.rkt"
         )
(current-https-protocol 'secure)
(define/contract (getTreeFromPortAndCloseIt port) (port? . -> . list?)
                 (let ([tree (html->xexp port)])
                   (close-input-port port)
                   tree
                   )
                 )
(provide getTreeFromPortAndCloseIt)
(define (htmlTreeFromUrl theUrl doRedirect)
  (case (url-scheme theUrl)
    [("file")
     (with-handlers ([exn:fail:filesystem:errno?
                       (lambda (e)
                         (makeErrorMessage (exn-message e))
                         )
                       ]
                     )
                    (getTreeFromPortAndCloseIt
                      (open-input-file (url->path theUrl))
                      )
                    )
     ]
    ;TODO is this the proper way to do https?
    [("http" "https")
     (with-handlers ([exn:fail:network:errno? makeErrorMessage])
                    (let-values ([(port headers)
                                  (get-pure-port/headers 
                                    theUrl
                                    #:connection (make-http-connection)
                                    )
                                  ]
                                 )
                      (let ([location (extract-field "location" headers)])
                        (if location
                          (begin 
                            (doRedirect location)
                            `(*TOP* "redirecting to " ,location)
                            )
                          (getTreeFromPortAndCloseIt port)
                          )
                        )
                      )
                    )
     ]
    [("bm") (bmUrl theUrl)]
    ; Should never reach here, but if it _does_ happen, this will handle for 
    ; that.
    [(#f) (makeErrorMessage "Can't handle a lack of a scheme")] 
    [else (makeErrorMessage (string-append "Can't handle this scheme "
                                           (url-scheme theUrl)
                                           )
                            )
          ]
    )
  )
(provide htmlTreeFromUrl)