#lang typed/racket/base
#|
This file is a part of the Bad-Mitten Browser and simplifies snip size math
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
(require typed/racket/class typed/racket/gui/base)
(provide get-snip-coordinates)
#|Returns false if snip not found, values x y width height if found|#
(: get-snip-coordinates :
   (Instance Editor<%>)
   (Instance Snip%)
   -> (Values Real Real Real Real))
(define (get-snip-coordinates editor snip)
  (let ([x : (Boxof Real) (box 0)]
        [y : (Boxof Real) (box 0)]
        [x+w : (Boxof Real) (box 0)]
        [y+h : (Boxof Real) (box 0)])
    (and (send editor get-snip-location snip x y #f)
         (send editor get-snip-location snip x+w y+h #t))
    (let ([actualX (unbox x)]
          [actualY (unbox y)])
      (values actualX
              actualY
              ((unbox x+w) . - . actualX)
              ((unbox y+h) . - . actualY)))))
