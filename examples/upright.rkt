#lang racket

(require "../geometry.rkt")
(require (prefix-in p: plot))

; Example usage:
;   (r upright)
(define (r f) (render f #:length 12 #:samples 30))

; u - upper, l - lower, c - center, f - flange

(define u-base
  (difference
   (extrude-z (triangle (P -2.001 .501 0) (P 0 8.498 0) (P 2.001 .501 0)) 0 1.687)
   (extrude-z (at (P 0 7.5 0) (square 4)) -.1 1.7)))
  
(define u-tri-pockets
  (extrude-z
   (union
    (triangle (P -1.592 1.312 0) (P -.861 4.233 0) (P -.105 2.06 0))
    (triangle (P 1.592 1.312 0) (P .105 2.06 0) (P .861 4.233 0))
    (triangle (P 0 2.062 0) (P -.755 4.233 0) (P .755 4.233 0)))
   .1 1.7))

(define u-pill-pocket
  (extrude-z
   (union
    (rectangle (P -.375 4.433 0) (P .375 5.068 0))
    (at (P -.375 4.75 0) (circle .3175))
    (at (P .375 4.75 0) (circle .3175)))
   .687 1.7))

(define u-holes
  (union
   (at (P -.375 4.75 0) (circle .118))
   (at (P .375 4.75 0) (circle .118))))

(define u-slope
  (rotate-y
   (triangle (P 2.295 7.792 0) (P 2.295 0 0) (P 0 7.792 0))
   (/ pi 2)))

(define u
  (difference
   u-base
   u-tri-pockets
   u-pill-pocket
   u-holes
   u-slope))

(define l-base
  (difference
   (extrude-z (triangle (P -2.02 -.415 0) (P 2.02 -.415 0) (P 0 -10.261 0)) 0 1.687)
   (extrude-z (at (P 0 -7.387 0) (square 4)) -.1 1.7)))
  
(define l-tri-pockets
  (extrude-z
   (union
    (triangle (P -1.646 -1.242 0) (P -.109 -2.06 0) (P -1.057 -4.112 0))
    (triangle (P .109 -2.06 0) (P 1.646 -1.242 0) (P 1.057 -4.112 0))
    (triangle (P 0 -2.062 0) (P .947 -4.112 0) (P -.947 -4.112 0)))
   .1 1.7))

(define l-cutout
  (at (P 0 -4.312 0) (reflect-y (trapezoid .875 1.674 .18))))

(define l-hole
  (at (P 0 -4.75 .373)
      (rotate-x
       (extrude-z (circle (/ .315 2)) -.75 .75)
       (/ pi 2))))

(define l-slope
  (rotate-y
   (triangle (P 2.316 0 0) (P 2.316 -7.604 0) (P 0 -7.604 0))
   (/ pi 2)))

(define l
  (difference
   l-base
   l-tri-pockets
   l-cutout
   l-hole
   l-slope))

(define f-base
  (union
   (difference
    (extrude-z
     (triangle (P 1.563 2.25 0) (P 3.598 1.35 0) (P 2.062 -.029 0))
     .753 1.128)
    (2d-half-space (P 3.239 1.027 0) (P 3.156 1.546 0)))
   (extrude-z
    (at (P 3.03 1.26 0) (circle .3125))
    .753 1.128)))

(define f-hole
  (at (P 3.03 1.26 0) (circle (/ .315 2))))

(define f-half
  (difference
   f-base
   f-hole))

(define f-fillet
  (difference
   (extrude-z
    (triangle (P 2.095 0 0) (P 2.612 .465 0) (P 2.612 -.465 0))
    .753 1.128)
   (at (P 3.03 0 0) (circle .625))))

(define f
  (union
   (reflect-y f-half)
   f-half
   f-fillet))

(define c-cutout
  (union 
   (circle (/ 3.292 2))
   (extrude-z (circle (/ 3.542 2)) -0.1 .512)
   (extrude-z (circle (/ 3.542 2)) 1.426 2)))

(define upright
  (difference
   (union
    (extrude-z (circle (/ 4.125 2)) 0 1.937)
    u
    l
    f)
   c-cutout))