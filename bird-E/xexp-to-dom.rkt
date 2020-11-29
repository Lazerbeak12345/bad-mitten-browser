#lang typed/racket/base
(require typed/racket/class
         "../consoleFeedback.rkt"
         "../xexp-type.rkt"
         "dom-elm.rkt"
         "text-node.rkt")
(provide xexp->dom)
(: html-br? (-> Any Boolean))
(define (html-br? theXexp)
  (and (xexp? theXexp)
	   (eq? 'br (xexp-name theXexp))))
(: xexp->dom (-> (Listof Xexp) (Listof Any))) ; TODO narrow return type
(define (xexp->dom xexp)
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
       (set! cleaned-elms (append cleaned-elms (list (assert last-string xexp?) elm)))
       (set! last-string "")]))
  (define doctype 'html5)
  (for/list ([elm cleaned-elms])
    (cond
      [(string? elm)
       (new text-node% [text elm])]
      #|[(xexp-comment? elm)
       (new comment-node% [xexp elm])]|#
      [(xexp? elm)
	   (new dom-elm%
			[name (xexp-name (ann elm Xexp))]
			[attrs (xexp-attrs elm)]
			[children (xexp->dom (xexp-children elm))])])))

