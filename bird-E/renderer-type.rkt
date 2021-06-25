#lang typed/racket/base
#|
This file is a part of the Bad-Mitten Browser and holds the Renderer% type
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
(require (only-in typed/net/url URL)
         (only-in typed/racket/class init)
         (only-in typed/racket/gui/base Area-Container<%>))
(provide Renderer%) ; See ./renderer.rkt
(define-type Renderer% (Class (init [initial-URL URL]
                                    [setUrl! (URL -> Void)]
                                    [parent (Instance Area-Container<%>)]
                                    [setTitle! (String -> Void)])
                              [navigate-to (URL -> Void)]
                              [set-document-title! (String -> Void)]))
(define-type Display (U 'block 'inline 'none))
(provide Display)
