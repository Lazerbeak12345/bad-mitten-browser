#lang typed/racket/base
#|
This file is a part of the Bad-Mitten Browser and handles network communication
Copyright (C) 2022  Nathan Fritzler jointly with the Free Software Foundation

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
|#
(require (only-in racket/port port->string)
         (only-in racket/list first)
         (only-in racket/string string-split)
         (only-in typed/net/url
                  combine-url/relative
                  current-url-encode-mode
                  get-pure-port/headers
                  make-http-connection
                  url
                  url->path
                  url->string
                  url-host
                  url-path
                  url-scheme
                  url-query
                  URL)
         (only-in typed/net/url-connect current-https-protocol)
         (only-in typed/net/head extract-field)
         (only-in "pages.rkt" bmUrl directory-page getTreeFromPortAndCloseIt makeErrorMessage)
         (only-in "xexp-type.rkt" Xexp))
(provide htmlTreeFromUrl
         makeInitTree)
;(current-https-protocol 'secure)
(current-https-protocol 'auto)
(current-url-encode-mode 'unreserved)
; Attempt to use the path to infer what a host might be. If it's up or same,
; it'll have to give up, though (removing the aforementioned up or same from
; the path)
(: makeUrlHaveHost : URL -> URL)
(define (makeUrlHaveHost theUrl)
  (if (url-host theUrl)
      theUrl
      (struct-copy url
                   theUrl
                   [host (let ([path (car (url-path theUrl))]) (if (string? path) path #f))]
                   [path (cdr (url-path theUrl))])))
(: htmlTreeFromUrl : URL (String -> Void) -> Xexp)
(define (htmlTreeFromUrl theUrl doRedirect)
  (case (url-scheme theUrl)
    [("file")
     (with-handlers ([exn:fail:filesystem? ;exn:fail:filesystem:errno?
                      (lambda ({e : exn}) (makeErrorMessage (exn-message e)))])
       (log-error "Check MIME type here")
       (define theUrl/path (url->path theUrl))
       (define path-string (bytes->string/locale (path->bytes theUrl/path)))
       (define show-hidden
         :
         Boolean
         #f)
       (for ([item (url-query theUrl)] #:when ((car item) . eq? . 'show-hidden))
         (set! show-hidden #t))
       (if (directory-exists? path-string)
           ; It's a dir
           (directory-page path-string theUrl/path show-hidden)
           ; It's a file
           (getTreeFromPortAndCloseIt (open-input-file path-string))))]
    [("http" "https")
     (with-handlers ([exn:fail:network:errno?
                      (lambda ({e : exn}) (makeErrorMessage (exn-message e)))])
       (if (not (url-host theUrl))
           (begin
             (log-info "Adjusting to have host")
             (doRedirect (url->string (makeUrlHaveHost theUrl)))
             '(*TOP*))
           (let-values ([(port headers)
                         (get-pure-port/headers theUrl #:connection (make-http-connection))])
             (log-warning "send better headers")
             (let ([location (extract-field #"location" headers)])
               (when location
                 (doRedirect (bytes->string/locale location))))
             ; We always want to see what their server says about
             ; it, just in case. (keep in mind the new location may
             ; not resolve)
             (log-info "headers\n~a" headers)
             (define content-type
               :
               String
               (let ([raw-content-type (extract-field #"content-type" headers)])
                 (if raw-content-type
                     (string-downcase
                      (first (string-split (bytes->string/locale raw-content-type) ";")))
                     "")))
             (case content-type
               [("text/html") (getTreeFromPortAndCloseIt port)]
               [("text/plain") `(*TOP* (code ,(port->string port)))]
               [else (makeErrorMessage (format "unsupported MIME type ~a" content-type))]))))]
    [("bm" "about") (bmUrl theUrl)]
    ; Should never reach here, but if it _does_ happen, this will handle for
    ; that.
    [(#f) (makeErrorMessage "Can't handle a lack of a scheme")]
    [else (makeErrorMessage (format "Can't handle the scheme '~a'" (url-scheme theUrl)))]))
(: makeInitTree : URL (URL -> Void) -> Xexp)
(define (makeInitTree initialUrl setTheUrl!)
  (let loop ([redirectionMax 10] [theUrl initialUrl])
    (define changedUrl
      :
      Boolean
      #f)
    (define tree
      (htmlTreeFromUrl theUrl
                       (lambda (newUrlStr)
                         (log-info "Redirect to ~a" newUrlStr)
                         (set! theUrl (combine-url/relative theUrl newUrlStr)))))
    (when changedUrl
      (if (0 . < . redirectionMax)
          (begin
            #|(place-channel-put this-place
                                 `(redirect ,(url->string theUrl)))|#
            (setTheUrl! theUrl)
            (loop (redirectionMax . - . 1) theUrl))
          (log-info "Hit max redirect!")))
    tree))
