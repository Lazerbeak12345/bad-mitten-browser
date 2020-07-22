#lang racket/base
(require racket/contract
         racket/list
         net/url
         html-parsing
         "consoleFeedback.rkt"
         )
(provide bmUrl makeErrorMessage getTreeFromPortAndCloseIt)
(define/contract (getTreeFromPortAndCloseIt port) (port? . -> . list?)
                 (print-warning "What if it's not an html file?")
                 (let ([tree (html->xexp port)])
                   (close-input-port port)
                   tree
                   )
                 )
(define/contract
  (makeErrorMessage e) (string? . -> . list?)
  `(*TOP* (*DECL* DOCTYPE html)
          (html (body (@ (style "height:100%"))
                      (strong (@ (style "margin:auto;"))
                              ,e
                              )
                      )
                )
          )
  )
(define/contract
  (bmUrl theUrl) (url? . -> . list?)
  (define/contract paths (listof (or/c string? 'up 'same))
                   (if (not (url-host theUrl))
                     (for/list [(path (url-path theUrl))]
                       (path/param-path path)
                       )
                     (cons (url-host theUrl)
                           (for/list [(path (url-path theUrl))]
                             (path/param-path path)
                             )
                           )
                     )
                   )
  (case (if (null? paths)
          "newtab"
          (first paths)
          )
    [("about" "urls")
     `(*TOP* (*DECL* DOCTYPE html)
             (html (head (title "Bad Mitten URLS"))
                   (body (h1 "Bad Mitten" (i "Browser"))
                         (ul ,(for/list ([theUrl (list "bm:about"
                                                       "bm:blank"
                                                       "bm:newtab"
                                                       "bm:urls"
                                                       )
                                                 ]
                                         )
                                (let ([url (url->string (string->url theUrl))])
                                  `(li (a (@ (href ,url)),url))
                                  )
                                )
                             )
                         )
                   )
             )
     ]
    [("blank") '(*TOP*)]
    [("newtab") '(*TOP* (*DECL* DOCTYPE html)
                        (html (head (title "New Tab"))
                              (body (h1 "Bad Mitten" (i "Browser")))
                              )
                        )
                ]
    [else (makeErrorMessage (format "Page does not exist '~a'"
                                    (url->string theUrl)
                                    )
                            )
          ]
    )
  )

