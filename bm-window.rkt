#lang racket
(require racket/gui/base)
; NOTE: I am specifically targeting the GNOME desktop enviroment, and plan to
;       follow their official appearance guidelines in the future.
(require net/url)
(require "consoleFeedback.rkt")
(require "tab.rkt")

; The main window
(define bm-window% (class object% (init links) ;TODO use signatures
					(define self-links (cond [(string? links) (list (netscape/string->url links))]
											 [((listof string?) links) (for/list [(link links)]
																		 (netscape/string->url link)
																		 )
																	   ]
											 [((listof url?) links) links]
											 [(url? links) (list links)]
										 )
					  )
					(define label "Bad-Mitten Browser")
					(define frame (new frame%
									   [label label]
									   [width 800] ; I just guessed these numbers. Works for gnome, works for me
									   [height 600]
									   [alignment '(center top)]
									   )
					  )
					(define locationPane (new horizontal-pane%
											  ;TODO text align vert-center
											  [parent frame]
											  [alignment '(left center)]
											  )
					  )
					(send locationPane stretchable-height #f)
					(define (locationChanged pane event)
					  (when (eq? (send event get-event-type) 'text-field-enter)
						(print-info "Location changed!")
						(send (getCurrentTab) locationChanged) ; They already have access to the url box
						)
					  )
					(define locationBack (new button%
												[parent locationPane]
												[label "Back"]
												[callback (lambda (button event)
															(send (getCurrentTab) back)
															)
														  ]
												)
					  )
					(define locationForward (new button%
												[parent locationPane]
												[label "Forward"]
												[callback (lambda (button event)
															(send (getCurrentTab) forward)
															)
														  ]
												)
					  )
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
					(define tabManagerPane (new horizontal-pane%
											  ;TODO text align vert-center
											  [parent frame]
											  [alignment '(right center)]
											  )
					  )
					(send tabManagerPane stretchable-height #f)
					(define addTab (new button%
										[parent tabManagerPane]
										[label "Add Tab"]
										[callback (lambda (button event)
													(print-error "Can't add tab yet")
													)
												  ]
										)
					  )
					(define closeTab (new button%
										  [parent tabManagerPane]
										  [label "Close Tab"]
										  [callback (lambda (button event)
													  (print-error "Can't remove tab yet")
													  )
													]
										  )
					  )
					(let-values ([(width height) (send closeTab get-graphical-min-size)])
					  ;(print-info (~a width))
					  (send locationBack min-width width)
					  (send locationForward min-width width)
					  (send locationReload min-width width)
					  (send addTab min-width width)
					  (send closeTab min-width width)
					  )
					(define last-tab-focused 0)
					(define tabs null)
					(define (getCurrentTab)
					  (list-ref tabs (send tab-elm get-selection))
					  )
					(define tab-elm (new tab-panel%
										 [choices (for/list ([link self-links]) (url->string link))]
										 [parent frame]
										 [callback (lambda (panel event)
													 (send (list-ref tabs last-tab-focused) unfocus)
													 (let ([index (send tab-elm get-selection)])
													   (send (list-ref tabs index) focus)
													   (set! last-tab-focused index)
													   )
													 (set-title (send (getCurrentTab) get-title))
													 )
												   ]
										 )
					  )
					(define (set-title title)
					  (send frame set-label (string-append title " - " label))
					  )
					(define (update-title)
					  (let ([title (send (getCurrentTab) get-title)])
						(set-title title)
						(send tab-elm set-item-label 0 title)
						)
					  )
					(super-new)
					(send frame show #t) ; Show frame before adding the tabs. It makes it a bit faster.
					(set! tabs (for/list ([tab-link self-links])
								   (new tab%
										[url tab-link]
										[locationBox locationBox]
										[locationBack locationBack]
										[locationForward locationForward]
										[tab-panel tab-elm]
										[update-title update-title]
										)
								   )
					  )
					(send (first tabs) focus)
					(update-title)
					)
  )
(provide bm-window%)

