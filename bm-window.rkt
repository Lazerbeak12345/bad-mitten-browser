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
  (define links (if (list? tab-links)
				  tab-links
				  (list tab-links)
				  )
	)
  (define tabs (for/list ([tab-link links])
				 (tab tab-link frame locationBox)
				 )
	)
  (send locationBox set-value (first links))
  (send frame show #t)
  )
(provide bm-window)

