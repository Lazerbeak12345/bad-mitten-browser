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
    (: place-dom-elm%-child ((Instance Dom-Elm%)
                             box-bounding
                             box-bounding
                             location
                             -> box-bounding))
    (define/private (place-dom-elm%-child element
                                          parent-min-size
                                          parent-max-size
                                          cursor)
                    (when (display . eq? . 'block)
                      (location-return-left! cursor parent-min-size)
                      (location-new-line! cursor occupied 0))
                    (define-values (child-bounding child-display)
                      (send element reposition
                            (box-bounding (location-x cursor)
                                          (location-y cursor)
                                          0
                                          0)
                            (box-bounding (location-x cursor)
                                          (location-y cursor)
                                          (box-bounding-w parent-max-size)
                                          (box-bounding-h parent-max-size))
                            cursor
                            display))
                    (when (display . eq? . 'block)
                      (location-return-left! cursor parent-min-size)
                      (location-new-line! cursor
                                          occupied
                                          (box-bounding-h child-bounding)))
                    child-bounding)
    (: place-string-snip%-child ((Instance String-Snip%)
                                 (Instance Pasteboard%)
                                 box-bounding
                                 box-bounding
                                 location
                                 -> box-bounding))
    (define/private (place-string-snip%-child element
                                              editor
                                              parent-min-size
                                              parent-max-size
                                              parent-cursor)
        (define-values (ex ey snip-width snip-height)
          (get-snip-coordinates editor element))
        (when (box-bounding-too-right?
                parent-max-size
                (box-bounding (location-x parent-cursor)
                              (location-y parent-cursor)
                              snip-width
                              snip-height))
          (location-return-left! parent-cursor parent-min-size)
          (location-new-line! parent-cursor occupied 0))
        (send editor move-to element
              (location-x parent-cursor)
              (location-y parent-cursor))
        (define old-x (location-x parent-cursor))
        (set-location-x! parent-cursor (old-x . + . snip-width))
        (box-bounding old-x
                      (location-y parent-cursor)
                      snip-width
                      snip-height))
    #|Reposition this element and its children|#
    (define/public
      (reposition parent-min-size parent-max-size parent-cursor parent-display)
      (define editor (cast (get-editor) (Instance Pasteboard%)))
      (set-box-bounding-x! occupied (location-x parent-cursor))
      (set-box-bounding-y! occupied (location-y parent-cursor))
      (unless (display . eq? . 'none)
        (for ([element init-children])
             (define child-occupied
               (if (element . is-a? . dom-elm%)
                 (place-dom-elm%-child (cast element (Instance Dom-Elm%))
                                       parent-min-size
                                       parent-max-size
                                       parent-cursor)
                 (place-string-snip%-child
                   (cast element (Instance String-Snip%))
                   editor
                   parent-min-size
                   parent-max-size
                   parent-cursor)))
             (add-box-boundings! occupied child-occupied)))
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
