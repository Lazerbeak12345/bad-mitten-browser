#lang racket
(require racket/gui/base)
; The code for a single tab (only)

(require "consoleFeedback.rkt")

(define tab% (class object% (init url locationBox tab-panel)
			   (define self-url url)
			   (define self-title self-url) ; Default to the url
			   (define self-locationBox locationBox)
			   (define self-tab-panel tab-panel)
			   (super-new)
			   (define/public (get-url) self-url)
			   (define/public (locationChanged)
				 (define new-url (send self-locationBox get-value))
				 (if (equal? self-url new-url)
				   (print-warning "Url value didn't change")
				   (begin
					 (print-info (string-append "Changing '"
												self-url
												"' to '"
												new-url
												"'"
												)
								 )
					 (set! self-url new-url)
					 (print-error "Can't actually change url")
					 )
				   )
				 )
			   (define/public (focus)
				 (print-info (string-append "Focusing '" self-url "'"))
				 (send self-locationBox set-value self-url)
				 (print-error "Can't actually change visibility")
				 )
			   (define/public (unfocus)
				 (print-info (string-append "Unfocusing '" self-url "'"))
				 (print-error "Can't actually change visibility")
				 )
			   (define/public (reload)
				 (print-info (string-append "Reloading '" self-url "'"))
				 (print-error "Can't actually reload")
				 )
			   (define/public (get-title)
				 self-title
				 )
			   (print-info (string-append "Opening tab '" self-url "'"))
			   )
  )
(provide tab%)

