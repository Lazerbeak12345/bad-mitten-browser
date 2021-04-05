#lang typed/racket/base
(provide dom-elm% Dom-Elm% Dom-Elm-Parent Dom-Elm-Child)
(require racket/function
         racket/string
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
                  [reposition-children (-> Exact-Nonnegative-Integer Void)]
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
         ;This is a temporary snip. Get rid of it and replace it with a proper
         ;snip of some sort at initialization
         (define snip : (Instance Snip%) (new string-snip%))
         (define/public (get-snip) snip)
         ; This is where the editor is stored so we don't have to climb the
         ; whole dom tree every time.
         #|(define _editor : (-> (Instance Editor<%>))
           (thunk
             (define e (send init-parent get-editor))
             (set! _editor (thunk e))
             e))|#
         (define/public (get-editor)
                        ; I really don't like this approach. If I could cash
                        ; it I would.
                        (send init-parent get-editor))
         ; This is the width that this element is occupying, regardless of
         ; box-sizing
         (define occupied-width : Exact-Nonnegative-Integer 0)
         (define/public
           (reposition-children parent-width)
           (print-info
             (format "reposition-children called on ~a parent-width: ~a"
               init-name parent-width))
           (for ([element init-children])
                (when (element . is-a? . dom-elm%)
                  ; Pass in the content width, not the occupied width to
                  ; account for padding.
                  (send (cast element (Instance Dom-Elm%)) reposition-children
                        occupied-width))))
         (define/public (set-document-title! title)
                        (send init-parent set-document-title! title))
         (define/public (get-count)
                        ; TODO does this need a fix?
                        (length init-children))
         (define/public (get-text a b [c #f])
                        (print-error "fix Dom-Elm% get-text")
                        (send snip get-text a b c))
         ; TODO define private vars for keeping track of box-sizing when needed
         (case init-name
           [(head script) (print-info (format "it's a ~a!" init-name))]
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
           [else (define editor (get-editor))
                 (send editor begin-edit-sequence #f)
                 (for ([element init-children])
                      (if (element . is-a? . snip%)
                          (send editor insert (cast element (Instance Snip%)))
                          (send editor insert
                                (send (cast element (Instance Dom-Elm%))
                                      get-snip))))
                 (send editor end-edit-sequence)])))
