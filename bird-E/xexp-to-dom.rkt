#lang typed/racket/base
(require typed/racket/class
		 typed/racket/snip
		 racket/string
         "../consoleFeedback.rkt"
         "../xexp-type.rkt"
         "dom-elm.rkt")
(provide xexp->dom)
(: html-br? (-> Any Boolean))
(define (html-br? theXexp)
  (and (xexp? theXexp)
       (not (string? theXexp))
       (eq? 'br (xexp-name theXexp))))
;(define-type Doctype (U 'html5 'quirks))
(define-type Doctype Symbol)
(print-warning "TODO: fix Doctype type in xexp-to-dom.rkt")
(: get-decl-doctype (-> Xexp-decl Doctype))
(define (get-decl-doctype theDecl)
  (print-error "get-decl-doctype not written yet")
  'quirks)
; NOTE: changes to #:doctype are not propigated upwards through the dom
(: xexp->dom ((Listof Xexp)
              [#:doctype Doctype]
              . -> .
              (Listof (U (Instance Dom-Elm%)
                         (Instance String-Snip%)))))
(define (xexp->dom xexp #:doctype [doctype 'quirks])
  ;(print-info (format "before: ~v" xexp))
  (define last-string : String "")
  (define cleaned-elms : (Listof Xexp) null)
  (define (append/last-string!)
	(let ([norm/str (string-normalize-spaces last-string)])
	  (unless (equal? norm/str "")
		(set! cleaned-elms (append cleaned-elms (list (assert norm/str xexp?))))
		(set! last-string ""))))
  ; First reduce the amount of strings we will need to keep in memory later
  (for ([elm xexp])
    (cond
      [(string? elm)
       (set! last-string (string-append last-string elm))]
      [(xexp-short? elm)
       (set! last-string (string-append last-string
                                        (string (xexp-short->char elm))))]
      [else (append/last-string!)
            (set! cleaned-elms (append cleaned-elms (list elm)))]))
  (append/last-string!)
  ;(print-info (format "after: ~v" cleaned-elms))
  ; Then go through and initialize the objects
  (for/list ([elm cleaned-elms]
			 #:when (let ([d (xexp-decl? elm)])
					  (when d (set! doctype (get-decl-doctype elm)))
					  (not d)))
    (cond
	  ; TODO handle style and script tag content
      [(string? elm)
       (make-object string-snip% elm)]
      [(or (xexp-with-attrs? elm)
           (xexp-no-attrs? elm))
       (new dom-elm%
            [name (xexp-name elm)]
            [attrs (xexp-attrs elm)]
            [children (xexp->dom (xexp-children elm)
                                 #:doctype doctype)])]
      [else (error "You've disloged a forign object in my parse expander!")])))

