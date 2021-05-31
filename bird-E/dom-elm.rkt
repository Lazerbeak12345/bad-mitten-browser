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
                        [children ((Instance Dom-Elm%)
                                   -> (Listof Dom-Elm-Child))])
                  [reposition
                    (box-bounding box-bounding location Display
                                  -> (Values box-bounding Display))]
                  [set-document-title! (String -> Void)]
                  [get-count (-> Exact-Nonnegative-Integer)]
                  [get-name (-> Symbol)]
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
    (define init-name : Symbol name) ; TODO make into field
    (define init-attrs : (Listof Xexp-attr) attrs)
    (define init-parent : Dom-Elm-Parent parent)
    (define init-children : (Listof Dom-Elm-Child) (children this))
    ; This is a temporary snip. Get rid of it and replace it with a proper snip
    ; of some sort at initialization
    (define snip : (Instance Snip%) (new string-snip%))
    (define/public (get-snip) snip)
    (define/public (get-name) init-name)
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
    ; This is the xy position and the size that this element is occupying
    (define occupied : box-bounding (box-bounding 0 0 0 0))
    ; Should this element even render?
    (define display : Display 'block)
    #|Reposition this element and its children|#
    (define/public
      (reposition parent-min-size parent-max-size parent-cursor parent-display)
      (print-info (format "reposition called on ~v" init-name))
      (define editor : (Instance Pasteboard%)
        (cast (get-editor) (Instance Pasteboard%)))
      (define tl-corner-x (box-bounding-x parent-min-size))
      (case display
        [(none)
         (print-info (format "not rendering ~v element" init-name))]
        [else
          (set-box-bounding-x! occupied (box-bounding-x parent-min-size))
          (set-box-bounding-y! occupied (box-bounding-y parent-min-size))
          (when (display . eq? . 'block)
            (set-box-bounding-w! occupied (box-bounding-w parent-max-size)))
          (for ([element init-children])
               (if
                 (element . is-a? . dom-elm%)
                 (let {[old-cursor-x (location-x parent-cursor)]
                       [old-cursor-y (location-y parent-cursor)]}
                          (define-values (child-occupied child-display)
                       (case display
                         [(block)
                          (send (cast element (Instance Dom-Elm%)) reposition
                                (box-bounding (location-x parent-cursor)
                                              (location-y parent-cursor)
                                              0
                                              0)
                                (box-bounding
                                  (box-bounding-x parent-max-size)
                                  (box-bounding-y parent-max-size)
                                  (box-bounding-w parent-max-size)
                                  ((box-bounding-h parent-max-size)
                                   . - .
                                   (box-bounding-h occupied)))
                                parent-cursor
                                display)]
                         [else
                           (send (cast element (Instance Dom-Elm%)) reposition
                                 (box-bounding (location-x parent-cursor)
                                               (location-y parent-cursor)
                                               0
                                               0)
                                 (box-bounding
                                   (box-bounding-x parent-max-size)
                                   (box-bounding-y parent-max-size)
                                   ((box-bounding-w parent-max-size)
                                    . - .
                                    (box-bounding-w occupied))
                                   ((box-bounding-h parent-max-size)
                                    . - .
                                    (box-bounding-h occupied)))
                                 parent-cursor
                                 display)]))
                          (when (not (old-cursor-x . = . (location-x parent-cursor)))
                            (set-box-bounding-w! occupied
                                                 ((box-bounding-w occupied)
                                                  . + .
                                                  (box-bounding-w child-occupied)))
                            (print-info "cursor-x changed!"))
                          (when (not (old-cursor-y . = . (location-y parent-cursor)))
                            (set-box-bounding-h! occupied
                                                 ((box-bounding-h occupied)
                                                  . + .
                                                  (box-bounding-h child-occupied)))
                            (print-info "cursor-y changed!")))
                 ; This is if the child is a string-snip
                (let-values ([(ex ey ew eh) ; Get the width and height
                              (get-snip-coordinates
                                editor
                                (cast element (Instance Snip%)))])
                  (define old-cursor-y (location-y parent-cursor))
                  (define old-cursor-x (location-x parent-cursor))
                  ; The absolute right side of the snip
                  (define snip-right-side (old-cursor-x . + . ew))
                  (if (snip-right-side . > .
                          (tl-corner-x . + . (box-bounding-w parent-max-size)))
                      (let ([new-y (old-cursor-y . + . eh)])
                        ; They need to be on a new line
                        ; Bottom left corner of element
                        (set! old-cursor-y new-y)
                        (set-location-y! parent-cursor new-y)
                        (set! old-cursor-x tl-corner-x)
                        (set-location-x! parent-cursor
                                         (tl-corner-x . + . ew))
                        (set-box-bounding-h! occupied
                                             ((box-bounding-h occupied)
                                              . + .
                                              eh)))
                      (begin
                        ; Same line
                        (set-location-x! parent-cursor snip-right-side)
                        (set-box-bounding-w!
                          occupied
                          (ew . + . (box-bounding-w occupied)))
                        (set-box-bounding-h!
                          occupied
                          (max eh (box-bounding-h occupied)))))
                  ; Move the snip where it goes
                  (send editor move-to
                        (cast element (Instance Snip%))
                        old-cursor-x
                        old-cursor-y))))])
      (when (display . eq? . 'block)
        (set-location-y! parent-cursor ((box-bounding-y occupied)
                                        . + .
                                        (box-bounding-h occupied)))
        (set-location-x! parent-cursor (box-bounding-x occupied)))
      (values occupied display))
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
