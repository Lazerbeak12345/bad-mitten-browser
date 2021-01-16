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
                              [children (Listof (U (Instance Dom-Elm%)
                                                   (Instance String-Snip%)))])
                        [reposition-children (-> Void)]))
(define dom-elm% : Dom-Elm%
  (class editor-snip%
    (init name attrs children)
    (super-new)
    (define init-name : Symbol name)
    (define init-attrs : (Listof Xexp-attr) attrs)
    (define init-children : (Listof (U (Instance Dom-Elm%)
                                       (Instance String-Snip%))) children)
    (define/public (reposition-children)
      (define editor : (U (Instance Pasteboard%)
                          (Instance Text%)
                          False)
        (send this get-editor))
      (when (and editor (editor . is-a? . pasteboard%))
        (for ([element init-children])
          (when (element . is-a? . dom-elm%)
            (send (cast element (Instance Dom-Elm%)) reposition-children))
          (print-info (format "is-owned? ~a" (send this is-owned?)))
          (print-info
            (format "extent: ~a"
                    (call-with-values (lambda()
                                        (get-snip-coordinates editor element))
                                      list))))))
    (send this set-align-top-line #t)
    (send this set-inset 0 0 0 0)
    (send this set-margin 0 0 0 0)
    (send this show-border #f)
    (let ([editor : (Instance Pasteboard%)
                  (pasteboard-div-lock (new pasteboard%))])
      (send this set-editor editor)
      (send editor begin-edit-sequence)
      (for ([element init-children])
        (send editor insert element))
      (send editor end-edit-sequence))))

