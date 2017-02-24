#lang racket

(require (prefix-in p: plot))
(require (prefix-in m: "math.rkt")
         (only-in "math.rkt" P P-x P-y P-z P-ρ P-θ P-ϕ))

;;
;; Shapes
;;

(define ((circle r) x y z)
  (- (+ (sqr x) (sqr y)) (sqr r)))

(define ((square l) x y z)
  (let ([d (/ l 2)])
    (max (- (- d) x) (- x d) (- (- d) y) (- y d))))

(define ((sphere r) x y z)
  (- (+ (sqr x) (sqr y) (sqr z)) (sqr r)))

(define ((cylinder r h) x y z)
  ((extrude-z (circle r) 0 h) x y z))

(define ((torus R r) x y z)
  (- (sqrt (+ (sqr (- R (sqrt (+ (sqr x) (sqr y)))))
              (sqr z)))
     r))

;;
;; Modifiers
;;

; center a shape at a point
(define ((at p f) x y z)
  (f (- x (P-x p)) (- y (P-y p)) (- z (P-z p))))

; union a variable number of shapes
(define ((union . fs) x y z)
  (apply min (map (λ (f) (f x y z)) fs)))

; intersection of a variable number of shapes
(define ((intersection . fs) x y z)
  (apply max (map (λ (f) (f x y z)) fs)))

; flip inside with outside for a shape
; the surface of the shape stays the same
(define ((inverse f) x y z)
  (- (f x y z)))

; extrude a 2d shape along the z-axis,
; assuming that the 2d shapes are
; infinite along the z-axis
(define ((extrude-z f zmin zmax) x y z)
  (max (f x y z) (- zmin z) (- z zmax)))

; repeat a shape infinitely along the x-axis
(define ((repeat-1d f d) x y z)
  (f (m:diff-nearest-mult x d) y z))

; repeat a shape infinitely along the xy-plane
(define ((repeat-2d f d1 d2) x y z)
  (f (m:diff-nearest-mult x d1) (m:diff-nearest-mult y d2) z))

; repeat a shape infinitely in 3 dimensions
(define ((repeat-3d f d1 d2 d3) x y z)
  (f (m:diff-nearest-mult x d1)
     (m:diff-nearest-mult y d2)
     (m:diff-nearest-mult z d3)))

; repeat a shape in a circle around the z-axis
(define ((repeat-polar f n) x y z)
  (match-let
      ([(vector x1 y1)
        (m:polar->cartesian
         (m:diff-nearest-mult (m:total-atan y x) (/ (* 2 pi) n))
         (sqrt (+ (sqr x) (sqr y))))])
    (f x1 y1 z)))

; repeat a shape in a circle around the z-axis
; and linearly along the z-axis
(define ((repeat-cylindrical f n d) x y z)
  ((repeat-polar f n) x y (m:diff-nearest-mult z d)))

; morph between two shapes by a percent
; n should be a number in [0, 1]
(define ((morph f g n) x y z)
  (+ (* (f x y z) (- 1 n))
     (* (g x y z) n)))

; scale a shape uniformly in 3 dimensions
(define ((scale f n) x y z)
  (let ([n (/ 1 n)])
    (f (* n x) (* n y) (* n z))))

; taper a 2d shape to a point
(define ((taper f h) x y z)
  (let ([n (/ (- h z) h)])
    (max (- 0 z)
         (- z h)
         ((scale f n) x y z))))

; taper a 2d shape until a ratio of the original
(define ((taper2 f h r) x y z)
  (let ([n (/ (- h (* (- h (* h r)) z)) h)])
    (max (- 0 z)
         (- z h)
         ((scale f n) x y z))))

; manually done loft
;(define x (* 2 (cos (/ pi 4))))
;(render (intersection (taper2 (circle x 0 0) 1 (/ 1/2 x))
;                      (taper2 (square 2 0 0) 1 0.5)) 2)

;;
;; Rendering
;;

(p:plot-width  600)
(p:plot-height 600)

; Takes a shape function and the side length of the viewing cube.
; Example usage:
;   (render (circle 1) 2)
(define (render f l)
  (let ([-l (/ (- l) 2)]
        [l  (/ l 2)])
    (p:plot3d
     (p:isosurface3d
      f
      0
      -l l -l l -l l)
     #:altitude 25)))
