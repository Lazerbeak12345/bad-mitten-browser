#lang racket
(require racket/gui/base)
; The code for a single tab (only)

(require "consoleFeedback.rkt")

(define tab% (class object% (init url parent locationBox)
			   (define self-url url)
			   (define self-parent parent)
			   (define self-locationBox locationBox)
			   (super-new)
			   (define/public (get-url) self-url)
			   (define/public (set-url! new-url)
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
			   (define/public (focus)
				 (print-info (string-append "Focusing '" self-url "'"))
				 (send self-locationBox set-value self-url)
				 (print-error "Can't actually change visibility")
				 )
			   (print-info (string-append "Opening tab '" self-url "'"))
			   )
  )
(provide tab%)

