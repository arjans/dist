#lang racket

(require (prefix-in p: plot))
(require (prefix-in m: "math.rkt"))

;;
;; Shapes
;;

(define ((point cx cy cz) x y z)
  (m:distance (list cx cy cz) (list x y z)))

(define ((line-z cx cy) x y z)
  (m:distance (list cx cy) (list x y)))

(define ((circle r cx cy) x y z)
  (- (+ (sqr (- cx x)) (sqr (- cy y))) (sqr r)))

(define ((square l cx cy) x y z)
  (let ([d (/ l 2)])
    (max (- (- d) x) (- x d) (- (- d) y) (- y d))))

(define ((sphere r cx cy cz) x y z)
  (- (+ (sqr (- cx x)) (sqr (- cy y)) (sqr (- cz z))) (sqr r)))

(define ((cylinder r cx cy cz h) x y z)
  ((extrude-z (circle r cx cy) 0 h) x y z))

(define ((torus cx cy cz R r) x y z)
  (- (sqrt (+ (sqr (- R (sqrt (+ (sqr x) (sqr y)))))
              (sqr z)))
     r))

;;
;; Modifiers
;;

(define ((union . fs) x y z)
  (apply min (map (λ (f) (f x y z)) fs)))

(define ((intersection . fs) x y z)
  (apply max (map (λ (f) (f x y z)) fs)))

(define ((inverse f) x y z)
  (- (f x y z)))

(define ((extrude-z f zmin zmax) x y z)
  (max (f x y z) (- zmin z) (- z zmax)))

(define ((repeat-1d f d) x y z)
  (f (m:diff-nearest-mult x d) y z))

(define ((repeat-2d f d1 d2) x y z)
  (f (m:diff-nearest-mult x d1) (m:diff-nearest-mult y d2) z))

(define ((repeat-3d f d1 d2 d3) x y z)
  (f (m:diff-nearest-mult x d1)
     (m:diff-nearest-mult y d2)
     (m:diff-nearest-mult z d3)))

(define ((repeat-polar f n) x y z)
  (match-let
      ([(vector x1 y1)
        (m:polar->cartesian
         (m:diff-nearest-mult (m:total-atan y x) (/ (* 2 pi) n))
         (sqrt (+ (sqr x) (sqr y))))])
    (f x1 y1 z)))

(define ((repeat-cylindrical f n d) x y z)
  ((repeat-polar f n) x y (m:diff-nearest-mult z d)))

(define ((morph f g n) x y z)
  (+ (* (f x y z) (- 1 n))
     (* (g x y z) n)))

(define ((scale f n) x y z)
  (let ([n (/ 1 n)])
    (f (* n x) (* n y) (* n z))))

(define ((taper f h) x y z)
  (let ([n (/ (- h z) h)])
    (max (- 0 z)
         (- z h)
         ((scale f n) x y z))))

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
(define (render f l)
  (let ([-l (/ (- l) 2)]
        [l  (/ l 2)])
    (p:plot3d
     (p:isosurface3d
      f
      0
      -l l -l l -l l)
     #:altitude 25)))
