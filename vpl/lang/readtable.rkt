#lang racket
(require syntax/readerr
         (prefix-in chc: "choices.rkt"))

(provide (rename-out [C-read read]
                     [C-read-syntax read-syntax]))

(define (C-read in)
  (parameterize ([current-readtable (make-C-readtable)])
    (read in)))

(define (C-read-syntax src in)
  (parameterize ([current-readtable (make-C-readtable)])
    (read-syntax src in)))

(define (make-C-readtable)
  (make-readtable (current-readtable)
                  #\$ 'terminating-macro read-choice))

(define read-choice
  (case-lambda
    [(ch in)
     (check-C-after (chc:read in) in (object-name in))]
    [(ch in src line col pos)
     (check-C-after (chc:read-syntax src in) in src)]))

(define (check-C-after val in src)
  (regexp-match #px"^\\s*" in) ; skip whitespace
  (let ([ch (peek-char in)])
    (unless (equal? ch #\$) (bad-ending ch src in))
    (read-char in))
  val)

(define (bad-ending ch src in)
  (let-values ([(line col pos) (port-next-location in)])
    ((if (eof-object? ch)
         raise-read-error
         raise-read-eof-error)
     "expected a closing `$'"
     src line col pos
     (if (eof-object? ch) 0 1))))
