#lang typed/racket/base
(require typed/racket/class
         typed/racket/gui/base
         "../consoleFeedback.rkt"
         "../xexp-type.rkt"
         "snip-utils.rkt"
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
    (super-new)
    (define init-name : Symbol name)
    (define init-attrs : (Listof Xexp-attr) attrs)
    (define init-children : (Listof (Instance Snip%)) children)
    (send this set-align-top-line #t)
    (send this set-inset 0 0 0 0)
    (send this set-margin 0 0 0 0)
    (send this show-border #f)
    (let ([editor : (Instance Pasteboard%)
                  (pasteboard-div-lock (new pasteboard%))])
      (send this set-editor editor)
      (for ([element init-children])
        (print-info (format "element: ~a" element))
        (send editor insert element)
        (print-info
          (format "extent: ~a"
                  (call-with-values (lambda()
                                      (get-snip-coordinates editor element))
                                    list)))))))

