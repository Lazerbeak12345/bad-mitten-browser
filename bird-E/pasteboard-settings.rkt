#lang typed/racket/base
(require mcfly typed/racket/class typed/racket/gui/base)
(provide pasteboard-div-lock)
(: pasteboard-div-lock (-> (Instance Pasteboard%)
                           (Instance Pasteboard%)))
(define (pasteboard-div-lock pasteboard)
  (send pasteboard set-dragable #f)
  pasteboard)

