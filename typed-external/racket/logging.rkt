#lang typed/racket/base
#|
This file is a part of the Bad-Mitten Browser and types racket/logging
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
(require/typed/provide
  racket/logging
  [with-logging-to-port (All (A) (-> Port
                                     (-> A)
                                     ;[#:logger Logger]
                                     (U 'none 'fatal 'error
                                     'warning 'info 'debug)
                                     #|[(U #f Symbol) ...]
                                     ...|#
                                     A))])
