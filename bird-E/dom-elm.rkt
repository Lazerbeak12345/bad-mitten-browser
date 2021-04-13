#lang typed/racket/base
(provide dom-elm% Dom-Elm% Dom-Elm-Parent Dom-Elm-Child)
(require racket/string
         typed/racket/class
         typed/racket/gui/base
         "../consoleFeedback.rkt"
         "../xexp-type.rkt"
         "renderer-type.rkt"
         "snip-utils.rkt")
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
                  [reposition-children (Real Real (Boxof (Pair Real Real))
                                             . -> . Void)]
                  [set-document-title! (-> String Void)]
                  [get-count (-> Exact-Nonnegative-Integer)]
                  [get-editor (-> (Instance Editor<%>))]
                  [get-snip (-> (Instance Snip%))]
                  [get-text
                    (->* (Exact-Nonnegative-Integer Exact-Nonnegative-Integer)
                         (Boolean)
                         String)]))
(define dom-elm% : Dom-Elm%
  (class
    object%
    (init name attrs parent children)
    (super-new)
    (define init-name : Symbol name)
    (define init-attrs : (Listof Xexp-attr) attrs)
    (define init-parent : Dom-Elm-Parent parent)
    (define init-children : (Listof Dom-Elm-Child) (children this))
    ; This is a temporary snip. Get rid of it and replace it with a proper snip
    ; of some sort at initialization
    (define snip : (Instance Snip%) (new string-snip%))
    (define/public (get-snip) snip)
    ; This is where the editor is stored so we don't have to climb the whole
    ; dom tree every time.
    #|(define _editor : (-> (Instance Editor<%>))
        (thunk
          (define e (send init-parent get-editor))
          (set! _editor (thunk e))
          e))|#
    (define/public (get-editor)
                   ; I really don't like this approach. If I could cash it I
                   ; would.
                   (send init-parent get-editor))
    ; This is the width that this element is occupying, regardless of box-sizing
    (define occupied-width : Real 0)
    ; This is the height that this element is occupying, regardless of box-sizing
    (define occupied-height : Real 0)
    ; Should this element even render?
    (define display : (U 'block 'inline 'none) 'block)
    (define/public
      (reposition-children parent-max-width return-point parent-cursor)
      (print-info
        (format (string-append "reposition-children called on ~a parent-width: "
                               "~a return-point: ~a cursor: ~a")
                init-name parent-max-width return-point parent-cursor))
      (define parent-init-x (car (unbox parent-cursor)))
      (define parent-init-y (cdr (unbox parent-cursor)))
      (define editor (get-editor))
      (case display
        [(none)
         (print-info (format "not rendering ~a element" init-name))]
        [(block inline)
         (when (display . eq? . 'inline)
           (print-warning "TODO: display is inline"))
         ; TODO for now this assumes everything is standard box-sizing
         (set! occupied-width parent-max-width); TODO margin
         (for ([element init-children])
              (if (element . is-a? . dom-elm%)
                  #|TODO Pass in the content width, not the occupied width to
                  account for padding.|#
                  ; Passes in a box for the cursor so the child can modify it
                  (send (cast element (Instance Dom-Elm%))
                        reposition-children
                        occupied-width
                        parent-init-x
                        parent-cursor)
                  ; This is if the child is a string-snip
                  (let-values ([(ex ey ew eh) ; Get the width and height
                                (get-snip-coordinates
                                  (cast editor (Instance Editor<%>))
                                  (cast element (Instance Snip%)))])
                    (define old-cursor (unbox parent-cursor))
                    (define old-cursor-y (cdr old-cursor))
                    (set-box! parent-cursor (cons (car old-cursor)
                                                  (old-cursor-y . + . eh)))
                    ; Move the snip where it goes
                    (send (cast editor (Instance Pasteboard%)) move-to
                          (cast element (Instance Snip%)) 0 old-cursor-y))))
         (set! occupied-height ((cdr (unbox parent-cursor))
                                . - .  parent-init-y))]))
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
      [(head script)
       (set! display 'none)
       (print-info (format "it's a ~a!" init-name))]
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
      [else
        (when (memq init-name '(a i b bold em strong span))
          (set! display 'inline))
        (define editor (get-editor))
        (for ([element init-children])
             (send editor insert
                   (if (element . is-a? . snip%)
                       (cast element (Instance Snip%))
                       (send (cast element (Instance Dom-Elm%)) get-snip))))])))
