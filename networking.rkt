#lang racket
(require net/url
         net/url-connect
         html-parsing
         "consoleFeedback.rkt"
         "pages.rkt"
         )
(current-https-protocol 'secure)
(define (getTreeFromPortAndCloseIt port)
  (let ([tree (html->xexp port)])
    (close-input-port port)
    tree
    )
  )
(provide getTreeFromPortAndCloseIt)
(define (htmlTreeFromUrl theUrl)
  (case (url-scheme theUrl)
    [("file")
     (with-handlers ([exn:fail:filesystem:errno? (lambda (e)
                                                   (makeErrorMessage
                                                     (exn-message e)
                                                     )
                                                   )
                                                 ]
                     )
                    (getTreeFromPortAndCloseIt (open-input-file (url->path 
                                                                  theUrl
                                                                  )
                                                                )
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
                      (print-info headers)
                      ; TODO get location from header and redirect
                      (print-error "Doesn't check for a redirect")
                      (getTreeFromPortAndCloseIt port)
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
