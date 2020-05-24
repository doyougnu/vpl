#lang racket

(require racket/fasl)

(define-namespace-anchor a)
(define ns (namespace-anchor->namespace a))

(module+ main
  (let go ()
    (display "Input: ")
    (define inp (read-line (current-input-port) 'any))
    (define op
      (match inp
        ["T"  '(* 1 2 3 4 5)]
        ["F"  '(+ 1 2 3 4 5)]))
    (+ 1 2 3 4 5 6 (eval op ns) 7 8 9 10)))
