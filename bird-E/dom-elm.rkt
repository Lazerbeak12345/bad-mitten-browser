#lang typed/racket/base
(provide dom-elm% Dom-Elm% Dom-Elm-Parent Dom-Elm-Child)
(require racket/string
         typed/racket/class
         typed/racket/gui/base
         "../consoleFeedback.rkt"
         "../xexp-type.rkt"
         "renderer-type.rkt")
(define-type Dom-Elm-Parent (U (Instance Dom-Elm%)
                               (Instance Renderer%)))
(define-type Dom-Elm-Child (U (Instance Dom-Elm%)
                              (Instance String-Snip%)))
(define-type
  Dom-Elm% (Class (init [name Symbol]
                        [attrs (Listof Xexp-attr)]
                        [parent Dom-Elm-Parent]
                        [children (-> (Instance Dom-Elm%)
                                      (Listof Dom-Elm-Child))])
                  [reposition-children (-> Void)]
                  [set-document-title! (-> String Void)]
                  [get-count (-> Exact-Nonnegative-Integer)]
                  [get-editor (-> (Instance Editor<%>))]
                  [get-snip (-> (Instance Snip%))]
                  [get-text
                    (->* (Exact-Nonnegative-Integer Exact-Nonnegative-Integer)
                         (Boolean)
                         String)]))
(define dom-elm% : Dom-Elm%
  (class object%
         (init name attrs parent children)
         (super-new)
         (define init-name : Symbol name)
         (define init-attrs : (Listof Xexp-attr) attrs)
         (define init-parent : Dom-Elm-Parent parent)
         (define init-children : (Listof Dom-Elm-Child) (children this))
         #|This is a temporary snip. Get rid of it and replace it with a proper
          |snip of some sort at initialization
          |#
         (define snip : (Instance Snip%) (new string-snip%))
         (define/public (get-snip) snip)
         (define/public
           (reposition-children)
           (print-error "TODO: reposition-children")
           (define editor : (Instance Editor<%>)
             (get-editor))
           (when (and editor (editor . is-a? . pasteboard%))
             (for ([element init-children])
                  (when (element . is-a? . dom-elm%)
                    (send (cast element (Instance Dom-Elm%))
                          reposition-children))
                  (print-info (format "snip-rows ~a" (get-snip-rows))))))
         (define/public (set-document-title! title)
                        (send init-parent set-document-title! title))
         (define/public (get-count)
                        (print-error "fix Dom-Elm% get-count")
                        (length init-children))
         (define/public (get-text a b [c #f])
                        (print-error "fix Dom-Elm% get-count")
                        (send snip get-text a b c))
         ; This is where the editor is stored so we don't have to climb the
         ; whole dom tree every time.
         #|(private _editor)
         (define _editor : (U (Instance Editor<%>) Void)
           (void))|#
         (define/public (get-editor)
                        #|(when (void? _editor)
                          (set! _editor (send init-parent get-editor)))
                        (cast _editor (Instance Editor<%>))|#
                        (send init-parent get-editor))
         (: get-snip-rows (-> (Listof (Listof Dom-Elm-Child))))
         (define (get-snip-rows)
           ; Reverse list of passed rows
           (define out : (Listof (Listof Dom-Elm-Child)) null)
           ; Reverse list of current row
           (define current-row : (Listof Dom-Elm-Child) null)
           ; Width of this dom-elm
           (print-error "TODO: get the width of the dom-elm")
           (define width 0)
           #|This might be wrong. `display:block` is as wide as possible and
            |`display:inline` is as small as possible
            |#
           ; The remaining width
           (define width-left width)
           (for ([elm init-children])
                (print-error "TODO: get the size of the dom-elm child")
                (define-values (x y w h)
                  #|(get-snip-coordinates (cast (send this get-editor)
                                              (Instance Editor<%>))
                                        elm)|#
                  (values 0 0 0 0))
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
         ; TODO define private vars for keeping track of box-sizing when needed
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
           [else (for ([element init-children])
                      (define editor (get-editor))
                      (send editor begin-edit-sequence #f)
                      (cond
                        [(element . is-a? . snip%)
                         (send editor insert (cast element (Instance Snip%)))]
                        [else
                          (send editor insert
                                (send (cast element (Instance Dom-Elm%))
                                      get-snip))])
                      (send editor end-edit-sequence))])))
