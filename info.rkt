#lang info
(define collection "dist")
(define deps '("base"
               "rackunit-lib"))
(define build-deps '("scribble-lib" "racket-doc"))
(define scribblings '(("scribblings/dist.scrbl" ())))
(define pkg-desc "Exploring distance fields for plot.")
(define version "0.0")
(define pkg-authors '(arjan))
