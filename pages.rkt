#lang typed/racket/base
(require typed/net/url "consoleFeedback.rkt")
(define-type Xexp (Listof Any))
(require/typed html-parsing [html->xexp (-> Input-Port Xexp)])
(require/typed racket/list [first (-> (Listof Any) Any)])
(provide bmUrl makeErrorMessage getTreeFromPortAndCloseIt)

(define-type Path/Param/List (Listof Path/Param))

(: getTreeFromPortAndCloseIt (-> Input-Port Xexp))
(define (getTreeFromPortAndCloseIt port)
  (let ([tree (html->xexp port)])
    (close-input-port port)
    tree))
(: makeErrorMessage (-> String Xexp))
(define (makeErrorMessage e)
  `(*TOP* (*DECL* DOCTYPE html)
          (html (body (@ (style "height:100%"))
                      (strong (@ (style "margin:auto;"))
                              ,e)))))
(: bmUrl (-> URL Xexp))
(define (bmUrl theUrl)
  (define-type String/Up/Same (Listof (U 'same 'up String)))
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
                         (ul ,(for/list : Xexp ([theUrl (list "bm:about"
                                                              "bm:blank"
                                                              "bm:bm"
                                                              "bm:newtab"
                                                              "bm:urls")])
                                (let ([url (url->string (string->url theUrl))])
                                  `(li (a (@ (href ,url)),url))))))))]
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
