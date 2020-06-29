#lang racket
(require net/url)
(require html-parsing)
(require "consoleFeedback.rkt")
(define (getTreeFromPortAndCloseIt port)
  (let ([tree (html->xexp port)])
	(close-input-port port)
	tree
	)
  )
(provide getTreeFromPortAndCloseIt)
(define (htmlTreeFromUrl theUrl)
  (case (url-scheme theUrl)
	[("file") (getTreeFromPortAndCloseIt (open-input-file (url->path theUrl)))]
	;TODO is this the proper way to do https?
	[("http" "https")
	 (with-handlers ([exn:fail:network:errno? (lambda (e)
												`(*TOP* (body (@ (style "height:100%"))
															  (strong (@ (style "margin:auto;"))
																	  ,(exn-message e)
																	  )
															  )
														)
												)
											  ]
					 )
					(let-values ([(port headers)
								  (get-pure-port/headers theUrl
														 #:connection (make-http-connection)
														 )
								  ]
								 )
					  (print-info headers)
					  (getTreeFromPortAndCloseIt port)
					  )
					)
	 ]
	[(#f) (print-error (string-append "Can't handle a lack of a scheme")) null]
	[else (print-error (string-append "Can't handle this scheme "
									  (url-scheme theUrl)
									  )
					   )
		  null
		  ]
	)
  )
(provide htmlTreeFromUrl)
