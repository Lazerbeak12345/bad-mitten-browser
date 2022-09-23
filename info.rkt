#lang info
(define collection "bad-mitten-browser")
(define deps '("base" "html-parsing"))
(define build-deps
  '("scribble-lib" "racket-doc" "rackunit-lib" "javascript" "net" "gui" "images" "fmt"))
(define scribblings '(("scribblings/bad-mitten-browser.scrbl" ())))
(define pkg-desc "A browser using the racket framework to be as small as possible.")
(define version "0.0")
(define pkg-authors '(nate))
