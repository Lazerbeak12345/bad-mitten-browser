#lang racket
(require racket/gui/base)
; The main window

; NOTE: I am specifically targeting the GNOME desktop enviroment, and plan to
;       follow their official appearance guidelines in the future.

(require "consoleFeedback.rkt")

(require "tab.rkt")

(define/contract
  (bm-window tab-links) ((or/c (listof string?)
							   string?
							   )
						 . -> .
						 void?
						 )
  (define frame (new frame%
					 [label "Bad-Mitten Browser"]
					 [width 800] ; I just guessed these numbers. Works for gnome, works for me
					 [height 600]
					 )
	)
  (define locationPanel (new horizontal-panel%
							 [parent frame]
							 [alignment '(left top)]
							 )
	)
  ; The location box. I would prefer if this were in the top bar instead.
  (define locationBox (new text-field%
						   [parent locationPanel]
						   [label "URL:"]
						   )
	)
  (define tabs (for/list ([tab-link (if (list? tab-links)
									  tab-links
									  (list tab-links)
									  )
									]
						  )
				 (new tab%
					  [url tab-link]
					  [parent frame]
					  [locationBox locationBox]
					  )
				 )
	)
  (send (first tabs) focus)
  (send frame show #t)
  )
(provide bm-window)

