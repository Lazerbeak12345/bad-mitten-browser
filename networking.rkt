#lang typed/racket/base
(require racket/port
         racket/list
         racket/string
         typed/net/url
         typed/net/url-connect
         typed/net/head
         "consoleFeedback.rkt"
         "pages.rkt"
         "xexp-type.rkt")
(provide htmlTreeFromUrl makeInitTree)
;(current-https-protocol 'secure)
(current-https-protocol 'auto)
(current-url-encode-mode 'unreserved)
; Attempt to use the path to infer what a host might be. If it's up or same,
; it'll have to give up, though (removing the aforementioned up or same from
; the path)
(: makeUrlHaveHost (-> URL URL))
(define (makeUrlHaveHost theUrl)
  (if (url-host theUrl)
    theUrl
    (struct-copy url theUrl
                 [host (let ([path (car (url-path theUrl))])
                         (if (string? path)
                           path
                           #f))]
                 [path (cdr (url-path theUrl))])))
(: htmlTreeFromUrl (-> URL (-> String Void) Xexp))
(define (htmlTreeFromUrl theUrl doRedirect)
  (case (url-scheme theUrl)
    [("file")
     ;TODO handle directories
     (with-handlers ([exn:fail:filesystem?;exn:fail:filesystem:errno?
                       (lambda ({e : exn})
                         (makeErrorMessage (exn-message e)))])
                    (print-warning "Check MIME type here")
                    (getTreeFromPortAndCloseIt
                      (open-input-file
                        (bytes->string/locale
                          ; Apparently no way to get out of the
                          ; Path-For-Some-System type aside from this...
                          (path->bytes 
                            (url->path theUrl))))))]
    [("http" "https")
     (with-handlers ([exn:fail:network:errno?
                       (lambda ({e : exn})
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
                        (let ([location (extract-field #"location" headers)])
                          (when location
                            (doRedirect (bytes->string/locale location))))
                        ; We always want to see what their server says about
                        ; it, just in case. (keep in mind the new location may
                        ; not resolve)
                        (print-info (format "headers\n~a" headers))
                        (define content-type : String
                          (let ([raw-content-type 
                                  (extract-field #"content-type" headers)])
                            (if raw-content-type
                              (string-downcase
                                (first (string-split
                                         (bytes->string/locale
                                           raw-content-type)
                                         ";")))
                              "")))
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
(: makeInitTree (-> (-> URL) (-> URL Void) Xexp))
(define (makeInitTree getTheUrl setTheUrl!)
  (let loop ([redirectionMax 10] [theUrl (getTheUrl)])
    (define changedUrl : Boolean #f)
    (define tree
      (htmlTreeFromUrl
        theUrl
        (lambda (newUrlStr)
          (print-info (format "Redirect to ~a" newUrlStr))
          (set! theUrl (combine-url/relative theUrl newUrlStr)))))
    (when changedUrl
      (if (< 0 redirectionMax)
        (begin
          #|(place-channel-put this-place
                                 `(redirect ,(url->string theUrl)))|#
          (setTheUrl! theUrl)
          (loop (- redirectionMax 1) theUrl))
        (print-info "Hit max redirect!")))
    tree))
