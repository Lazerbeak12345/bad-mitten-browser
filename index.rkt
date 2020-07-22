#lang racket
(require "consoleFeedback.rkt" "bm-window.rkt")
(print-info "Opening Bad-Mitten Browser…")
(new bm-window% [links (for/list ([arg (current-command-line-arguments)])
                         arg
                         )
                       ]
     )

