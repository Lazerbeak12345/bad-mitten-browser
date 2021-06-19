#lang typed/racket/base
#|
This file is a part of the Bad-Mitten Browser and holds the box-bounding utils
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
(struct box-bounding ([x : Real]
                      [y : Real]
                      [w : Real]
                      [h : Real]))
(provide box-bounding box-bounding? box-bounding-x box-bounding-y box-bounding-w
         box-bounding-h)
(: box-bounding-right (box-bounding -> Real))
(define (box-bounding-right bb)
  ((box-bounding-x bb) . + . (box-bounding-w bb)))
(: box-bounding-bottom (box-bounding -> Real))
(define (box-bounding-bottom bb)
  ((box-bounding-y bb) . + . (box-bounding-h bb)))
(provide add-box-boundings)
(: add-box-boundings : box-bounding box-bounding -> box-bounding)
(define (add-box-boundings left right)
  (define right-right (box-bounding-right right))
  (define right-bottom (box-bounding-bottom right))
  (define left-w (box-bounding-w left))
  (when ((box-bounding-right left) . < . right-right)
    (set! left-w (right-right . - . (box-bounding-x left))))
  (define left-h (box-bounding-h left))
  (when ((box-bounding-bottom left) . < . right-bottom)
    (set! left-h (right-bottom . - . (box-bounding-y left))))
  (box-bounding (box-bounding-x left)
                (box-bounding-y left)
                left-w
                left-h))
(: box-bounding-too-right? (box-bounding
                            box-bounding
                            -> Boolean))
(define (box-bounding-too-right? parent child)
  ((box-bounding-right child) . >= . (box-bounding-right parent)))
(provide box-bounding-right box-bounding-bottom box-bounding-too-right?)

(struct location ([x : Real]
                  [y : Real]))
(provide location location? location-x location-y)
(: location-return-left : location box-bounding -> location)
(define (location-return-left cursor min-size)
  (location (box-bounding-x min-size)
            (location-y cursor)))
(provide location-return-left)
(: location-new-line : location box-bounding Real -> location)
(define (location-new-line cursor occupied h)
  (location (location-x cursor)
            ((box-bounding-y occupied)
             . + . (max (box-bounding-h occupied) h))))
(provide location-new-line)
(: location-nl/cr : location box-bounding Real box-bounding -> location)
(define (location-nl/cr cursor occupied h min-size)
  (location-return-left (location-new-line cursor occupied h)
                        min-size))
(provide location-nl/cr)
