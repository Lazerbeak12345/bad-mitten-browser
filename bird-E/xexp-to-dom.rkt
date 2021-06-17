#lang typed/racket/base
#|
This file is a part of the Bad-Mitten Browser and makes dom trees from xexps
Copyright (C) 2021  Nathan Fritzler jointly with the Free Software Foundation

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
|#
(require racket/string
         typed/racket/class
         typed/racket/snip
         "../consoleFeedback.rkt"
         "../xexp-type.rkt"
         "dom-elm.rkt"
         "renderer-type.rkt")
(provide xexp->dom)
(: html-br? (Any -> Boolean))
(define (html-br? theXexp)
  (and (xexp? theXexp)
       (not (string? theXexp))
       (eq? 'br (xexp-name theXexp))))
;(define-type Doctype (U 'html5 'quirks))
(define-type Doctype Symbol)
(print-warning "TODO: fix Doctype type in xexp-to-dom.rkt")
(: get-decl-doctype (Xexp-decl -> Doctype))
(define (get-decl-doctype theDecl)
  (print-error "get-decl-doctype not written yet")
  'quirks)
; NOTE: changes to #:doctype are not propigated upwards through the dom
(: xexp->dom ((Listof Xexp)
              #:parent Dom-Elm-Parent
              [#:doctype Doctype]
              -> (Listof Dom-Elm-Child)))
(define (xexp->dom xexp #:parent parent #:doctype [doctype 'quirks])
  ;(print-info (format "before: ~v" xexp))
  (define last-string : String "")
  (define cleaned-elms : (Listof Xexp) null)
  (define (append/last-string!)
    (let ([norm/str (string-normalize-spaces last-string)])
      (unless (equal? norm/str "")
        (set! cleaned-elms (append cleaned-elms (list (assert norm/str xexp?))))
        (set! last-string ""))))
  ; First reduce the amount of strings we will need to keep in memory later
  (for ([elm xexp])
    (cond
      [(string? elm)
       (set! last-string (string-append last-string elm))]
      [(xexp-short? elm)
       (set! last-string (string-append last-string
                                        (string (xexp-short->char elm))))]
      [else (append/last-string!)
            (set! cleaned-elms (append cleaned-elms (list elm)))]))
  (append/last-string!)
  ;(print-info (format "after: ~v" cleaned-elms))
  ; Then go through and initialize the objects
  (for/list ([elm cleaned-elms]
             #:when (let ([d (xexp-decl? elm)])
                      (when d (set! doctype (get-decl-doctype elm)))
                      (not d)))
    (cond ; TODO handle style and script tag content
      [(string? elm)
       (make-object string-snip% elm)]
      [(or (xexp-with-attrs? elm)
           (xexp-no-attrs? elm))
       (new dom-elm%
            [name (xexp-name elm)]
            [attrs (xexp-attrs elm)]
            [parent parent]
            [children (lambda (child-parent)
                        (xexp->dom (xexp-children elm)
                                   #:parent child-parent
                                   #:doctype doctype))])]
      [else (error 'xexp->dom
                   "You've disloged a forign object in my parse expander!")])))
