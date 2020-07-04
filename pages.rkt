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
                   [("newtab")
                    '(*TOP* (*DECL* DOCTYPE html)
                            (html (head (title "New Tab"))
                                  (body (h1 "Bad Mitten" (i "Browser")))
                                  )
                            )
                    ]
                   [else (makeErrorMessage "Page does not exist on 'bm:' url")]
                   )
                 )

