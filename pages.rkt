#lang typed/racket/base
#|
This file is a part of the Bad-Mitten Browser and holds the build-in pages
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
(require (only-in racket/list first)
         (only-in typed/net/url
                  path/param-path
                  url->string
                  url-host url-path
                  Path/Param
                  URL)
         (only-in "xexp-type.rkt" Xexp))
(define-type String/Up/Same (Listof (U 'same 'up String)))
(require/typed html-parsing [html->xexp (Input-Port -> Xexp)])
(provide bmUrl
         directory-page
         makeErrorMessage
         getTreeFromPortAndCloseIt
         String/Up/Same)

(define-type Path/Param/List (Listof Path/Param))

(: getTreeFromPortAndCloseIt : Input-Port -> Xexp)
(define (getTreeFromPortAndCloseIt port)
  (let ([tree (html->xexp port)])
    (close-input-port port)
    tree))
(: makeErrorMessage : String -> Xexp)
(define (makeErrorMessage e)
  `(*TOP* (*DECL* DOCTYPE html)
          (html (body (@ (style "height:100%"))
                      (strong (@ (style "margin:auto;"))
                              ,e)))))
(: directory-page : Path-String Path-For-Some-System Boolean -> Xexp)
(define (directory-page path-string theUrl/path show-hidden)
  (log-warning "TODO add control links")
  (define dir-list (directory-list path-string))
  `(*TOP*
     (*DECL* DOCTYPE html)
     (html
       (body
         (h1 ,(format "File Listing of ~a" path-string))
         (ul
           .
           ,(for/list
              : (Listof Xexp)
              ([name dir-list])
              (let ([name/str (bytes->string/locale (path->bytes name))])
                (if (((string-ref name/str 0) . eq? . #\.)
                     . and . (not show-hidden))
                  ""
                  (let ([full/location
                          (bytes->string/locale
                            (path->bytes (build-path theUrl/path name)))])
                    `(li (a (@ (href ,(string-append "file://" full/location)))
                            ,(if (directory-exists? full/location)
                               (string-append name/str "/")
                               name/str))))))))))))
(: bmUrl : URL -> Xexp)
(define (bmUrl theUrl)
  (: paths String/Up/Same)
  (define paths
    (let ([paths-before (for/list : String/Up/Same [(path (url-path theUrl))]
                                  (path/param-path path))]
          [host (url-host theUrl)])
      (if (not host)
        paths-before
        (cons host paths-before))))
  (case (if (null? paths)
            "newtab"
            (first paths))
    [("about" "urls" "bm")
     `(*TOP* (*DECL* DOCTYPE html)
             (html (head (title "Bad Mitten URLS"))
                   (body (h1 "Bad Mitten" (i "Browser"))
                         (ul  . ,(for/list : (Listof Xexp)
                                           ([theUrl : String '("bm:about"
                                                               "bm:blank"
                                                               "bm:bm" 
                                                               "bm:newtab"
                                                               "bm:urls")])
                                           `(li (a (@ (href ,theUrl))
                                                   ,theUrl)))))))]
    [("blank") '(*TOP*)]
    [("newtab") '(*TOP* (*DECL* DOCTYPE html)
                        (html (head (title "New Tab"))
                              (body (h1 "Bad Mitten" (i "Browser"))
                                    (span
                                      (@ (style "font-size:.5em; color:grey"))
                                      "See the"
                                      (& nbsp)
                                      (a (@ (href "bm:urls"))
                                         "built-in urls")))))]
    [else (makeErrorMessage (format "Page does not exist '~a'"
                                    (url->string theUrl)))])) 
