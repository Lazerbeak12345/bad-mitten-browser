#lang typed/racket/base
(provide Xexp)
(define-type Xexp (U (Pairof Symbol (Listof Xexp))
                     String
                     Symbol))
