#lang racket
(require "parser.rkt")

(define (read-syntax path port)
  (define parse-tree (parse path (make-tokenizer port)))
  (define module-datum `(module html-mod html/expander
						  ,parse-tree
						  )
	)
  (datum->syntax #f module-datum)
  )
(provide read-syntax)

(require brag/support) ; provides `lexeme` (?)
(define (make-tokenizer port)
  (define (next-toeken)
	(define bf-lexer (lexer
					   [(char-set "<") lexeme]
					   [any-char (next-token)]
					   )
	  )
	(bf-lexer port)
	)
  next-token
  )

