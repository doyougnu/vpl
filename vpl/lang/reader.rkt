#lang s-exp syntax/module-reader
racket
#:read Chc-read
#:read-syntax Chc-read-syntax

(require (prefix-in Chc- "readtable.rkt"))
