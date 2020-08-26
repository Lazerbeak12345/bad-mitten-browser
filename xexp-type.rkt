#lang typed/racket/base
(provide Xexp)
(define-type Xexp (Listof (U Xexp String Symbol Number)))
