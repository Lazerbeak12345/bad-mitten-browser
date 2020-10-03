#lang typed/racket/base
(require typed/racket/class "../consoleFeedback.rkt" "dom-event.rkt")
(provide Event-Target% event-target%)
(define-type Event-Target%
             (Class [addEventListener (-> String (-> Any) Void)]
                    [dispatchEvent (-> (Instance Event%) Boolean)]
                    [removeEventListener (-> String (-> Any) Void)]))
(define event-target% : Event-Target%
  (class object%
    (define/public (addEventListener name callback)
      (error "event bound when not written!"))
    (define/public (dispatchEvent theEvent)
      (error "event distpatched when not written!")
      #t)
    (define/public (removeEventListener name callback)
      (error "event removed when not written!"))
    (print-info "event-target% initted!")
    (super-new)))
