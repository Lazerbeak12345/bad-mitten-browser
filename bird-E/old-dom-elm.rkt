#lang typed/racket/base
(require racket/string
         typed/racket/class
         typed/racket/gui/base
         "../consoleFeedback.rkt"
         "../xexp-type.rkt"
         "renderer-type.rkt"
         "snip-utils.rkt"
         "pasteboard-settings.rkt")
(provide old-dom-elm% Old-Dom-Elm%)
(define-type Old-Dom-Elm% (Class
                        #:implements/inits Editor-Snip%
                        (init [name Symbol]
                              [attrs (Listof Xexp-attr)]
                              [parent (U (Instance Old-Dom-Elm%)
                                         (Instance Renderer%))]
                              [children
                                (-> (Instance Old-Dom-Elm%)
                                    (Listof (U (Instance Old-Dom-Elm%)
                                               (Instance String-Snip%))))])
                        [reposition-children (-> Void)]
                        [set-document-title! (-> String Void)]))
(define old-dom-elm% : Old-Dom-Elm%
  (class editor-snip%
    (init name attrs parent children)
    (super-new)
    (define init-name : Symbol name)
    (define init-attrs : (Listof Xexp-attr) attrs)
    (define init-parent : (U (Instance Old-Dom-Elm%)
                             (Instance Renderer%)) parent)
    (define init-children : (Listof (U (Instance Old-Dom-Elm%)
                                       (Instance String-Snip%)))
      (children this))
    (: get-snip-rows (-> (Listof (Listof (Instance Snip%)))))
    (define (get-snip-rows)
      ; Reverse list of passed rows
      (define out : (Listof (Listof (Instance Snip%))) null)
      ; Reverse list of current row
      (define current-row : (Listof (Instance Snip%)) null)
      ; Width of this editor-snip%
      (define width
        (let-values
          ([(_ _a width _b)
            (get-snip-coordinates
              (cast (send init-parent get-editor)
                    (Instance Editor<%>))
              this)])
          width))
      ; The remaining width
      (define width-left width)
      (for ([elm init-children])
        (define-values (x y w h)
          (get-snip-coordinates (cast (send this get-editor)
                                      (Instance Editor<%>))
                                elm))
        (define width-post-addition (width-left . - . w))
        ; TODO ask the elmement if it's inline
        (define elm-inline #t)
        (if (and (>= width-post-addition 0)
                 elm-inline)
          (begin (set! current-row (cons elm current-row))
                 (set! width-left width-post-addition))
          (begin (set! out (cons (reverse current-row) out))
                 (set! current-row (list elm))
                 (set! width-left width))))
      (reverse (cons (reverse current-row) out)))
    (define/public (reposition-children)
      (define editor : (U (Instance Pasteboard%)
                          (Instance Text%)
                          False)
        (send this get-editor))
      (when (and editor (editor . is-a? . pasteboard%))
        (for ([element init-children])
          (when (element . is-a? . old-dom-elm%)
            (send (cast element (Instance Old-Dom-Elm%)) reposition-children))
        (print-info (format "snip-rows ~a" (get-snip-rows))))))
    (define/public (set-document-title! title)
                   (send init-parent set-document-title! title))
    (send this set-align-top-line #t)
    (send this set-inset 0 0 0 0)
    (send this set-margin 0 0 0 0)
    (send this show-border #f)
    (case init-name
      [(head) (print-info "it's a head!")]
      [(title)
       (define title "")
       (for ([element init-children])
            ; TODO assert that it's a string snip
            (set! title
              (string-append
                title
                " "
                (send element get-text
                      0
                      (cast (send element get-count) Nonnegative-Integer)
                      #t))))
       (set-document-title! (string-trim title))]
      [else (let ([editor : (Instance Pasteboard%)
                          (pasteboard-div-lock (new pasteboard%))])
              (send this set-editor editor)
              (send editor begin-edit-sequence)
              (for ([element init-children])
                   (send editor insert element))
              (send editor end-edit-sequence))])))

