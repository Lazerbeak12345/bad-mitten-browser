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
									   [alignment '(center top)]
									   )
					  )
					(define (locationChanged pane event)
					  (when (eq? (send event get-event-type) 'text-field-enter)
						(print-info "Location changed!")
						(send (getCurrentTab) locationChanged) ; They already have access to the url box
						)
					  )
					(define locationPane (new horizontal-pane%
											  ;TODO text align vert-center
											  [parent frame]
											  [alignment '(left center)]
											  )
					  )
					(send locationPane stretchable-height #f)
					(define locationReload (new button%
												[parent locationPane]
												[label "Reload"]
												[callback (lambda (button event)
															(send (getCurrentTab) reload)
															)
														  ]

												)
					  )
					; The location box. I would prefer if this were in the top bar instead.
					(define locationBox (new text-field%
											 [parent locationPane]
											 [label "URL:"]
											 [callback locationChanged]
											 )
					  )
					(send locationBox stretchable-height #t)
					(define last-tab-focused 0)
					(define (getCurrentTab)
					  (list-ref tabs (send tab-elm get-selection))
					  )
					(define tab-elm (new tab-panel%
										 [choices self-links]
										 [parent frame]
										 [callback (lambda (panel event)
													 (print-info "Changing to tab number ")
													 (define index (send tab-elm get-selection))
													 (println index)
													 (send (list-ref tabs last-tab-focused) unfocus)
													 (send (list-ref tabs index) focus)
													 (set! last-tab-focused index)
													 )
												   ]
										 )
					  )
					(define tabs (for/list ([tab-link self-links])
								   (new tab%
										[url tab-link]
										[locationBox locationBox]
										[tab-panel tab-elm]
										)
								   )
					  )
					(super-new)
					(send (first tabs) focus)
					(send frame show #t)
					)
  )
(provide bm-window%)

