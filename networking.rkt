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
(define/contract
  (htmlTreeFromUrl theUrl doRedirect)
  (-> url? (-> (or/c string?  bytes?) void?) list?)
  (case (url-scheme theUrl)
    [("file")
     ;TODO handle directories
     (with-handlers ([exn:fail:filesystem?;exn:fail:filesystem:errno?
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
                                    ; If we do this, we can't get the latest
                                    ; url
                                    ;#:redirections 100
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
