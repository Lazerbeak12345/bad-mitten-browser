#lang typed/racket/base
(require typed/racket/class
		 typed/racket/snip
         "../consoleFeedback.rkt"
         "../xexp-type.rkt"
         "dom-elm.rkt")
(provide xexp->dom)
(: html-br? (-> Any Boolean))
(define (html-br? theXexp)
  (and (xexp? theXexp)
	   (eq? 'br (xexp-name theXexp))))
; NOTE: changes to #:doctype are not propigated upwards through the dom
(: xexp->dom (-> (Listof Xexp) [#:doctype (U 'html5 'quirks)] (Listof Any))) ; TODO narrow return type
(define (xexp->dom xexp #:doctype [doctype 'html5])
  (define last-string : String "")
  (define cleaned-elms : (Listof Xexp) null)
  (for ([elm xexp])
    (cond
      [(string? elm)
       (set! last-string (string-append last-string elm))]
      [(html-br? elm)
       (set! last-string (string-append last-string "\n"))]
      [(xexp-short? elm)
	   (set! last-string (string-append (string (xexp-short->char elm))))]
	  [else
		(set! cleaned-elms (append cleaned-elms
								   (if (not (eq? last-string ""))
									 (list (assert last-string xexp?) elm)
									 (list elm))))
		(set! last-string "")]))
  (for/list ([elm cleaned-elms]
			 #:when (if (xexp-decl? elm)
					  (begin (print-error "Needs to update doctype")
							 #f)
					  #t))
    (cond
      [(string? elm)
	   ; As it turns out, this built-in does everything I need.
	   (make-object string-snip% elm)]
      #|[(xexp-comment? elm)
       (new comment-node% [xexp elm])]|#
      [(xexp? elm)
	   (new dom-elm%
			[name (xexp-name (ann elm Xexp))]
			[attrs (xexp-attrs elm)]
			[children (xexp->dom (xexp-children elm) #:doctype doctype)])])))

