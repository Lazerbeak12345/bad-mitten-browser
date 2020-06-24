#lang racket

(define-macro (html-module-begin PARSE-TREE)
			  #'(#%module-begin
				 PARSE-TREE)
			  )
(provide (rename-out [html-module-begin #%module-begin]))

(define-macro (html-document 
; Continue defining macros for every single statment in ./parser.rkt
