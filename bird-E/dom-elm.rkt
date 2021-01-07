#lang typed/racket/base
(require typed/racket/class
		 typed/racket/gui/base
		 "../consoleFeedback.rkt"
		 "../xexp-type.rkt"
     "pasteboard-settings.rkt")
(provide dom-elm% Dom-Elm%)
(define-type Dom-Elm% (Class
                        #:implements/inits Editor-Snip%
                        (init [name Symbol]
                              [attrs (Listof Xexp-attr)]
                              [children (Listof (Instance Snip%))])))
(define dom-elm% : Dom-Elm%
  (class editor-snip%
    (init name attrs children)
    (define pasteboard-instance : (Instance Pasteboard%)
      (pasteboard-div-lock (new pasteboard%)))
    (super-new)
    (define init-name : Symbol name)
    (define init-attrs : (Listof Xexp-attr) attrs)
    (define init-children : (Listof (Instance Snip%)) children)
    (print-info (format "name: ~a" init-name))
    (print-info (format "attrs: ~a" init-attrs))
    (print-info (format "children: ~a" init-children))
    (send this set-editor pasteboard-instance)
    (for ([element init-children])
      (print-info (format "element: ~a" element))
      (send pasteboard-instance insert element))))

