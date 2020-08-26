#lang typed/racket/base
(require typed/racket/class
         racket/string
         racket/list
         "../consoleFeedback.rkt"
         "../xexp-type.rkt"
         "element.rkt"
         "html-element.rkt"
         "node.rkt")
(provide Dom-Root-Node% dom-root-node%)
(: determineTypeOfXexpRoot (-> Xexp (U 'html5 'unknown)))
(define (determineTypeOfXexpRoot xexp)
  (if (and (eq? '*TOP* (car xexp))
           (list? (cdr xexp))
           (list? (second xexp))
           (eq? '*DECL* (first (assert (second xexp) list?)))
           (symbol? (second (assert (second xexp) list?)))
           (equal?
             "DOCTYPE"
             (string-upcase
               (symbol->string
                 (assert (second (assert (second xexp) list?)) symbol?))))
           (symbol? (third (assert (second xexp) list?)))
           ; Commented out because if it's xml like, html5 should do okay, but
           ; not great, with it.
           #|; TODO xhtml should work too
           (string-prefix? ; prefix because this works for html4
             (string-downcase
               (symbol->string
                 (assert (third (assert (second xexp) list?)) symbol?)))
             "html")|#)
    'html5
    'unknown))
; A union because this could be svg or something else aside from void (only on
; an error)
(define-type Element%/unknown (U (Instance HTML-Element%) Void))
(: xexp->element%/unknown (-> Xexp Element%/unknown))
(define (xexp->element%/unknown xexp)
  (case (determineTypeOfXexpRoot xexp)
    [(html5) (xexp->html-element% xexp)]
    [else (print-error (format "The following document (in sexp form)~a~v"
                               " could not be identified!\n"
                               xexp))]))
(define-type Dom-Root-Node% (Class #:implements Node%
                                   (init [initial-tree Xexp])))
(define dom-root-node% : Dom-Root-Node%
  (class node%
    (init [initial-tree : Xexp])
    (define dom : Element%/unknown
      (xexp->element%/unknown initial-tree))
    (super-new)))
