#lang racket
(require syntax/readerr)

(provide read read-syntax)

(define (read in)
  (syntax->datum (read-syntax #f in)))

(define (read-syntax src in)
  (skip-whitespace in)
  (read-choice src in))

(define (skip-whitespace in)
  (regexp-match #px"^\\s*" in))

(define (read-choice src in)
  (define-values (line col pos) (port-next-location in))

  (define expr-match
    (regexp-match #px"^(.*?)<(.*?),(.*?)>" in))

  (define (to-syntax v delta span-str)
    (datum->syntax #f v (make-srcloc delta span-str)))

  (define (make-srcloc delta span-str)
    (and line
         (vector src line (+ col delta) (+ pos delta)
                 (string-length span-str))))

  (define (parse-expr s delta)
    (match (regexp-match #rx"^(.*?)<(.*?),(.*?)>$" s)
      [(list _ dimension left-alt right-alt)
       (to-syntax `(list ,dimension
                         ,(datum->syntax #f left-alt)
                         ,(datum->syntax #f right-alt)) delta s)]))

  (unless expr-match
    (raise-read-error "bad choice syntax"
                      src line col pos
                      (and pos (- (file-position in) pos))))

  (parse-expr (bytes->string/utf-8 (car expr-match)) 0))
