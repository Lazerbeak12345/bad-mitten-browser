#lang racket/base
(require racket/contract
         net/url
         net/url-connect
         net/head
         "pages.rkt"
         "consoleFeedback.rkt"
         )
(provide htmlTreeFromUrl)
(current-https-protocol 'secure)
(define/contract
  (makeUrlHaveHost theUrl) (-> url? url?)
  (if (url-host theUrl)
    theUrl
    (url (url-scheme theUrl)
         (url-user theUrl)
         (path/param-path (car (url-path theUrl))) ; url-host
         (url-port theUrl)
         (url-path-absolute? theUrl)
         (cdr (url-path theUrl)) ; url-path
         (url-query theUrl)
         (url-fragment theUrl)
         )
    )
  )
(define/contract
  (htmlTreeFromUrl theUrl doRedirect)
  (-> url? (-> string? void?) list?)
  (case (url-scheme theUrl)
    [("file")
     ;TODO handle directories
     (with-handlers ([exn:fail:filesystem?;exn:fail:filesystem:errno?
                       (lambda (e)
                         (makeErrorMessage (exn-message e))
                         )
                       ]
                     )
                    (print-warning "Check MIME type here")
                    (getTreeFromPortAndCloseIt
                      (open-input-file (url->path theUrl))
                      )
                    )
     ]
    [("http" "https")
     (with-handlers ([exn:fail:network:errno?
                       (lambda (e)
                         (makeErrorMessage (exn-message e))
                         )
                       ]
                     )
                    (if (not (url-host theUrl))
                      (begin
                        (print-info "Adjusting to have host")
                        (doRedirect (url->string (makeUrlHaveHost theUrl)))
                        '(*TOP*)
                        )
                      (let-values
                        ([(port headers)
                          (get-pure-port/headers 
                            theUrl
                            #:connection (make-http-connection)
                            ; If we do this, we can't get the latest url
                            ;#:redirections 100
                            )
                          ]
                         )
                        (print-warning "send better headers")
                        (print-warning "Check MIME type here")
                        (let ([location (extract-field "location" headers)])
                          (when location
                            (doRedirect location)
                            )
                          )
                        ; We always want to see what their server says about
                        ; it, just in case. (keep in mind the new location may
                        ; not resolve)
                        (getTreeFromPortAndCloseIt port)
                        )
                      )
                    )
     ]
    [("bm" "about") (bmUrl theUrl)]
    ; Should never reach here, but if it _does_ happen, this will handle for 
    ; that.
    [(#f) (makeErrorMessage "Can't handle a lack of a scheme")] 
    [else (makeErrorMessage (format "Can't handle the scheme '~a'"
                                    (url-scheme theUrl)
                                    )
                            )
          ]
    )
  )
