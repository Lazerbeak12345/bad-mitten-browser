#lang racket
(require racket/gui/base)
; The main window

; NOTE: I am specifically targeting the GNOME desktop enviroment, and plan to
;       follow their official appearance guidelines in the future.

(require "consoleFeedback.rkt")

(require "tab.rkt")

(define bm-window% (class object% (init links) ;TODO use signatures
					(define self-links (cond [((listof string?) links) links]
											 [(string? links) (list links)]
										 )
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
					(define tabs (for/list ([tab-link self-links])
								   (new tab%
										[url tab-link]
										[parent frame]
										[locationBox locationBox]
										)
								   )
					  )
					(super-new)
					(send (first tabs) focus)
					(send frame show #t)
					(define/public (get-locationBox)
					  locationBox
					  )
					(define/public (get-tabs)
					  tabs
					  )
					)
  )
(provide bm-window%)

