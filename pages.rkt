#lang racket
(require net/url)
(provide bmUrl
         makeErrorMessage
         )
(define/contract 
  (makeErrorMessage e) (string? . -> . list?)
  `(*TOP* (html (body (@ (style "height:100%"))
                      (strong (@ (style "margin:auto;"))
                              ,e
                              )
                      )
                )
          )
  )
(define/contract (bmUrl theUrl) (url? . -> . list?)
                 (define/contract 
                   paths (listof (or/c string? 'up 'same))
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
                 (case (first paths)
                   [("about" "urls")
                    `(*TOP* (*DECL* DOCTYPE html)
                            (html (head (title "Bad Mitten URLS"))
                                  (body (h1 "Bad Mitten" (i "Browser"))
                                        #|(ul (li ,(linkFromUrl "bm:about"))
                                            (li ,(linkFromUrl "bm:blank"))
                                            (li ,(linkFromUrl "bm:newtab"))
                                            (li ,(linkFromUrl "bm:urls"))
                                            )|#
                                        (ul ,(for/list ([theUrl (list
                                                                  "bm:about"
                                                                  "bm:blank"
                                                                  "bm:newtab"
                                                                  "bm:urls"
                                                                  )
                                                                ]
                                                        )
                                               (let
                                                 ([url (url->string
                                                         (string->url theUrl)
                                                         )
                                                       ]
                                                  )
                                                 `(li (a (@ (href ,url)),url))
                                                 )
                                               )
                                            )
                                        )
                                  )
                            )
                    ]
                   [("blank") '(*TOP*)]
                   [("newtab")
                    '(*TOP* (*DECL* DOCTYPE html)
                            (html (head (title "New Tab"))
                                  (body (h1 "Bad Mitten" (i "Browser")))
                                  )
                            )
                    ]
                   [else
                     (makeErrorMessage
                       (format "Page does not exist '~a'" (url->string theUrl))
                       )
                     ]
                   )
                 )

