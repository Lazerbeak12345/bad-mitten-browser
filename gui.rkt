#lang racket
(require racket/gui/base)
; Abstract away app-menus, windows and the like.

; NOTE: I am specifically targeting the GNOME desktop enviroment, and plan to
;       follow their official appearance guidelines in the future.

(require "consoleFeedback.rkt")

(define/contract
  (bm-window tabs) ((or/c (listof string?)
						  string?
						  )
					. -> .
					void?
					)
  (define actualTabs (if (list? tabs)
					   tabs
					   (list tabs)
					   )
	)
  (define frame (new frame%
					 [label "Bad-Mitten Browser"]
					 [width 800] ; I just guessed these numbers. Works for gnome, works for me
					 [height 600]))

  (for ([tab actualTabs])
	(print-info (string-append "Opening tab '" tab "'"))
	)

  (send frame show #t)
  )
(provide bm-window)

