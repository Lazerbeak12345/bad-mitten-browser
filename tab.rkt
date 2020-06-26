#lang racket
(require racket/gui/base)
(require net/url)
(require html-parsing)
(require "consoleFeedback.rkt")
; The code for a single tab (only)
(define tab% (class object% (init url locationBox tab-panel)
			   (define self-url url)
			   (define (url->readable self-url)
				 ;(path/param-path (last (url-path self-url)))
				 (url->string self-url)
				 )
			   (define self-title (url->readable self-url)) ; Default to the url
			   (define self-locationBox locationBox)
			   (define self-tab-panel tab-panel)
			   (define (parse)
				 (print-info (string-append "Parsing " (url->string self-url)))
				 (case (url-scheme self-url)
				   ; TODO check if it's a directory
				   [("file") (println (html->xexp (open-input-file (url->path self-url))))]
				   [(#f) (print-error (string-append "Can't handle a lack of a scheme"))]
				   [else (print-error (string-append "Can't handle this scheme " (url-scheme self-url)))]
				   )
				 )
			   (super-new)
			   (define/public (get-url) self-url)
			   (define/public (locationChanged)
				 (define new-url (netscape/string->url (send self-locationBox get-value)))
				 (if (equal? self-url new-url)
				   (print-warning "Url value didn't change")
				   (begin
					 (print-info (string-append "Changing '"
												(url->string self-url)
												"' to '"
												(url->string new-url)
												"'"
												)
								 )
					 (send self-locationBox set-value (url->string new-url))
					 (set! self-url new-url)
					 (parse)
					 )
				   )
				 )
			   (define/public (focus)
				 (print-info (string-append "Focusing '" (url->string self-url)"'"))
				 (send self-locationBox set-value (url->string self-url))
				 (print-error "Can't actually change visibility")
				 )
			   (define/public (unfocus)
				 (print-info (string-append "Unfocusing '" (url->string self-url)"'"))
				 (print-error "Can't actually change visibility")
				 )
			   (define/public (reload)
				 (print-info (string-append "Reloading '" (url->string self-url) "'"))
				 (parse); That's as simple as it gets, folks!
				 )
			   (define/public (get-title)
				 self-title
				 )
			   ;(print-info (string-append "Opening tab '" (url->string self-url) "'"))
			   (parse)
			   )
  )
(provide tab%)

