#lang racket/base
(require racket/contract
         racket/port
         racket/list
         racket/string
         net/url
         net/url-connect
         net/head
         "pages.rkt"
         "consoleFeedback.rkt")
(provide htmlTreeFromUrl makeInitTree)
(current-https-protocol 'secure)
(current-url-encode-mode 'unreserved)
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
         (url-fragment theUrl))))
(define/contract
  (htmlTreeFromUrl theUrl doRedirect)
  (-> url? (-> string? void?) list?)
  (case (url-scheme theUrl)
    [("file")
     ;TODO handle directories
     (with-handlers ([exn:fail:filesystem?;exn:fail:filesystem:errno?
                       (lambda (e)
                         (makeErrorMessage (exn-message e)))])
                    (print-warning "Check MIME type here")
                    (getTreeFromPortAndCloseIt
                      (open-input-file (url->path theUrl))))]
    [("http" "https")
     (with-handlers ([exn:fail:network:errno?
                       (lambda (e)
                         (makeErrorMessage (exn-message e)))])
                    (if (not (url-host theUrl))
                      (begin
                        (print-info "Adjusting to have host")
                        (doRedirect (url->string (makeUrlHaveHost theUrl)))
                        '(*TOP*))
                      (let-values
                        ([(port headers)
                          (get-pure-port/headers 
                            theUrl
                            #:connection (make-http-connection))])
                        (print-warning "send better headers")
                        (let ([location (extract-field "location" headers)])
                          (when location (doRedirect location)))
                        ; We always want to see what their server says about
                        ; it, just in case. (keep in mind the new location may
                        ; not resolve)
                        (print-info (format "headers\n~a" headers))
                        (define content-type
                          (string-downcase
                            (first (string-split
                                     (extract-field "content-type" headers)
                                     ";"))))
                        (case content-type
                          [("text/html")
                           (getTreeFromPortAndCloseIt port)]
                          [("text/plain")
                           `(*TOP* (code ,(port->string port)))]
                          [else (makeErrorMessage
                                  (format "unsupported MIME type ~a"
                                          content-type))]))))]
    [("bm" "about") (bmUrl theUrl)]
    ; Should never reach here, but if it _does_ happen, this will handle for 
    ; that.
    [(#f) (makeErrorMessage "Can't handle a lack of a scheme")] 
    [else (makeErrorMessage (format "Can't handle the scheme '~a'"
                                    (url-scheme theUrl)))]))
(define/contract
  (makeInitTree getTheUrl setTheUrl!) (-> url? (-> url? void?) list?)
  (let loop ([redirectionMax 10] [theUrl (getTheUrl)])
    (define changedUrl #f)
    (define tree
      (htmlTreeFromUrl
        theUrl
        (lambda (newUrlStr)
          (print-info (format "Redirect to ~a" newUrlStr))
          (set! changedUrl (combine-url/relative theUrl
                                                 newUrlStr)))))
    (when changedUrl
      (if (< 0 redirectionMax)
        (begin
          (set! theUrl changedUrl)
          #|(place-channel-put this-place
                                 `(redirect ,(url->string changedUrl)))|#
          (setTheUrl! theUrl)
          (loop (- redirectionMax 1) theUrl))
        (print-info "Hit max redirect!")))
    tree))
