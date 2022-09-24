#!/usr/bin/env racket
#lang typed/racket/base
#|
This file is a part of the Bad-Mitten Browser and serves as the entry point
Copyright (C) 2022 Lazerbreak12345 jointly with the Free Software Foundation

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
(module+ test
  (log-error "No tests written!?")
  #f)
(module+ main
  (require (only-in racket/cmdline command-line)
           (only-in typed/racket/class new)
           (only-in "shell/bm-window.rkt" bm-window% Bm-window%)
           (only-in "typed-external/racket/logging.rkt" with-logging-to-port))
  (: arg-links (Listof String))
  (define arg-links '())
  (: web-driver-api-enabled Boolean)
  (define web-driver-api-enabled #f)
  (command-line
   #:usage-help "A www browser using the racket framework to be as small as possible."
   #:once-each
   ("--enable-web-driver-api"
    =>
    (lambda (arg) (set! web-driver-api-enabled #t))
    ; TODO Multiple help strings don't work, nor does
    ; string-join
    '("Activate an API made to allow automated testing frameworks to control your browser.\n\tDisabled by default for security reasons."))
   #:args links
   (set! arg-links
         (for/list :
           (Listof String)
           ((link links))
           (assert link string?))))
  (if web-driver-api-enabled
      (begin
        (log-fatal "Code for webdriver has not been written yet")
        (exit 1))
      (with-logging-to-port (current-output-port)
                            (lambda ()
                              (log-error "TODO: make verbosity a cli argument")
                              (log-info "Opening Bad-Mitten Browser…")
                              (new bm-window% [links arg-links]))
                            'warning)))
