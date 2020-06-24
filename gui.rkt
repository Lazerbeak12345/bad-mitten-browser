#lang racket ;TODO we should specifically use the GUI language
; Abstract away app-menus, windows and the like.

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
  (print-error "window not written yet!") ;TODO write window
  (for ([tab actualTabs])
	(print-info (string-append "opening tab " tab))
	)
  )
(provide bm-window)

