#lang racket
(require "consoleFeedback.rkt"
         "bm-window.rkt"
         )
;(new bm-window% [links "test.html"])
#|(new bm-window% [links (list
                           "///home/nate/projects/bad-mitten-browser/test.html"
                           "http://localhost:8081"
                           #;"invalid.html" ; TODO handle invalid urls
                           ; TODO handle huge html
                           #;"file:///usr/racket/doc/net/url.html" 
                           ; TODO handle huge html
                           "file:///usr/racket/doc/index.html" 
                           )
                         ]
       )|#
(print-info "Opening Bad-Mitten Browser...")
(new bm-window% [links (for/list ([arg (current-command-line-arguments)])
                         arg
                         )
                       ]
     )

