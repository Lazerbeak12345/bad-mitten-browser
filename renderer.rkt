#lang racket/base
(require racket/gui/base racket/class "consoleFeedback.rkt")
(provide make-canvas)
(define (make-canvas parent)
  (define last-width 1)
  (define last-height 1)
  (define sharedBytes (make-shared-bytes 4))
  (define bitmap-buffer (make-object bitmap% 1 1))
  (new
    canvas%
    [parent parent]
    [style '(no-autoclear)]
    [paint-callback
      (lambda (canvas dc)
        (print-info "painting")
        (define-values (w h) (send canvas get-scaled-client-size))
        (if (or (not (= last-width w))
                (not (= last-height h)))
          (begin
            (set! sharedBytes (make-shared-bytes (* w h 4) 255))
            #|(place-channel-put (get-tab-place)
                               `(canvas-size ,w ,h ,sharedBytes))|#
            (set! bitmap-buffer (make-object bitmap% sharedBytes w h))
            (set! last-width w)
            (set! last-height h))
          (send bitmap-buffer
                set-argb-pixels
                0
                0
                last-width
                last-height
                sharedBytes))
        (send dc draw-bitmap bitmap-buffer 0 0)
        ; TODO make this loop _not_ be a busy loop, but still do 80fps
        (thread (lambda()
                  (sync (system-idle-evt))
                  (sleep 1); TODO remove
                  ; Blocks, apparently?
                  (send canvas refresh))))]))
