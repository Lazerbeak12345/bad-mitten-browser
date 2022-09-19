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
  (require (only-in "consoleFeedback.rkt" print-error))
  (print-error "No tests written!?")
  #f)
(module+ main
  (require (only-in typed/racket/class new)
           (only-in "consoleFeedback.rkt" print-info)
           (only-in "bm-window.rkt" bm-window% Bm-window%))
  (print-info "Opening Bad-Mitten Browser…")
  (new bm-window% [links (vector->list (current-command-line-arguments))]))
