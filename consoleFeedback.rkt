#lang typed/racket/base
#|
This file is a part of the Bad-Mitten Browser and binds metadata to log info
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
(require typed/racket/date)
(provide print-info print-warning print-error VerbosityLevel)
; Print information, warnings, and the like to the console that this was run
; from
(define-type VerbosityLevel
             (U 'all 'errors 'warnings 'errors-and-warnings 'none))
(: verbosity (Parameterof VerbosityLevel))
(define verbosity (make-parameter 'all))
(define (getDisplayTime)
  (date-display-format 'iso-8601) 
  (date->string (current-date) #t))
(define-type PrintThingy (-> String Void))
(: print-info PrintThingy)
(define (print-info information)
  (when (eq? verbosity 'all)
    (displayln (format "[~a] INFO:    ~a" (getDisplayTime) information))))
(: print-warning PrintThingy)
(define (print-warning information)
  (when (memq (verbosity) '(all warnings errors-and-warnings))
    (displayln (format "[~a] WARNING: ~a" (getDisplayTime) information))))
(: print-error PrintThingy)
(define (print-error information)
  (when (memq (verbosity) '(all errors errors-and-warnings))
    (displayln (format "[~a] ERROR:   ~a" (getDisplayTime) information)
               (current-error-port))))
