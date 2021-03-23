#lang typed/racket/base
(require typed/racket/class typed/racket/gui/base "../consoleFeedback.rkt")
(provide get-snip-coordinates)
#|Returns false if snip not found, values x y width height if found|#
(: get-snip-coordinates ((Instance Editor<%>)
                         (Instance Snip%)
                         . -> . (Values Real Real Real Real)))
(define (get-snip-coordinates editor snip)
  (let ([x : (Boxof Real) (box 0)]
        [y : (Boxof Real) (box 0)]
        [x+w : (Boxof Real) (box 0)]
        [y+h : (Boxof Real) (box 0)])
    (and (send editor get-snip-location snip x y #f)
         (send editor get-snip-location snip x+w y+h #t))
    (let ([actualX (unbox x)]
          [actualY (unbox y)])
      (values actualX
              actualY
              ((unbox x+w) . - . actualX)
              ((unbox y+h) . - . actualY)))))
