#lang racket
(require "consoleFeedback.rkt")
(print-info "Opening Bad-Mitten Browser...")

(print-warning "Opening test.html, as I don't know how to do command line args")
(require "bm-window.rkt")
;(new bm-window% [links "test.html"])
(new bm-window% [links (list
						 "///home/nate/projects/bad-mitten-browser/test.html"
						 "http://localhost:8081"
						 #;"invalid.html" ; TODO handle invalid urls
						 #;"file:///usr/racket/doc/net/url.html" ; TODO handle huge html
						 "file:///usr/racket/doc/index.html" ; TODO handle huge html
						 )
					   ]
	 )

