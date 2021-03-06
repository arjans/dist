#lang typed/racket

(require (prefix-in p: plot))
(require (prefix-in m: "math.rkt")
         (only-in "math.rkt" P P-x P-y P-z P-ρ P-θ P-ϕ))

(provide (all-defined-out)
         P)

; See: https://en.wikipedia.org/wiki/Signed_distance_function
(define-type Distance-Function (-> Real Real Real Real))

;;
;; Shapes
;;

(: circle (-> Nonnegative-Real Distance-Function))
(define ((circle r) x y z)
  (- (P-ρ (P x y 0)) r))

(: square (-> Nonnegative-Real Distance-Function))
(define ((square l) x y z)
  (let ([d (/ l 2)])
    (max (- (- d) x) (- x d) (- (- d) y) (- y d))))

(: rectangle (-> P P Distance-Function))
; Example usage:
;   (rectangle (P 0 0 0) (P 2 1 0))
(define ((rectangle p1 p2) x y z)
  (match-let ([(P x1 y1 z1) p1]
              [(P x2 y2 z2) p2])
    (let ([xmin (min x1 x2)]
          [xmax (max x1 x2)]
          [ymin (min y1 y2)]
          [ymax (max y1 y2)])
      (max (- xmin x) (- x xmax) (- ymin y) (- y ymax)))))

(: sphere (-> Nonnegative-Real Distance-Function))
(define ((sphere r) x y z)
  (- (P-ρ (P x y z)) r))

(: cylinder (-> Nonnegative-Real Nonnegative-Real Distance-Function))
(define ((cylinder r h) x y z)
  ((extrude-z (circle r) 0 h) x y z))

(: torus (-> Nonnegative-Real Nonnegative-Real Distance-Function))
(define ((torus R r) x y z)
  (- (sqrt (+ (sqr (- R (sqrt (+ (sqr x) (sqr y)))))
              (sqr z)))
     r))

(: 2d-half-space (-> P P Distance-Function))
; create a half-space parallel to z-axis
; a half-space divides space into two -
; inside and outside
(define ((2d-half-space p1 p2) x y z)
  (match-let* ([(P x1 y1 z1) p1]
               [(P x2 y2 z2) p2])
    (- (* (- y1 y2) (- x x2)) (* (- x1 x2) (- y y2)))))

(: triangle (-> P P P Distance-Function))
; must give triangle points in clockwise order
; Example usage:
;   (triangle (P 0 0 0) (P 0 1 0) (P 1 0 0))
(define ((triangle p1 p2 p3) x y z)
  ((intersection
    (2d-half-space p1 p2)
    (2d-half-space p2 p3)
    (2d-half-space p3 p1)) x y z))

(: trapezoid (-> Nonnegative-Real Nonnegative-Real Nonnegative-Real Distance-Function))
; for symmetric trapezoids only
; takes: height of trapezoid, smaller width of trapezoid
; and base of triangle
(define ((trapezoid h w b) x y z)
  (let* ([w (/ w 2)]
         [-w (- w)])
    ((union
      (rectangle (P -w 0 0) (P w h 0))
      (triangle (P w 0 0) (P w h 0) (P (+ w b) 0 0))
      (triangle (P -w 0 0) (P (- -w b) 0 0) (P -w h 0)))
     x y z)))

;;
;; Modifiers
;;

(: at (-> P Distance-Function Distance-Function))
; center a shape at a point
(define ((at p f) x y z)
  (f (- x (P-x p)) (- y (P-y p)) (- z (P-z p))))

(: reflect-x (->* (Distance-Function) (Real) Distance-Function))
; reflect across x=o plane
(define ((reflect-x f [o 0]) x y z)
  (f (- (* 2 o) x) y z))

(: reflect-y (->* (Distance-Function) (Real) Distance-Function))
; reflect across y=o plane
(define ((reflect-y f [o 0]) x y z)
  (f x (- (* 2 o) y) z))

(: reflect-z (->* (Distance-Function) (Real) Distance-Function))
; reflect across z=o plane
(define ((reflect-z f [o 0]) x y z)
  (f x y (- (* 2 o) z)))

(: rotate-x (-> Distance-Function Real Distance-Function))
; Example usage:
;   (rotate-x (circle 1) (/ pi 4))
(define ((rotate-x f θ) x y z)
  (f
   x
   (+ (* (cos θ) y) (* (- (sin θ)) z))
   (+ (* (sin θ) y) (* (cos θ) z))))

(: rotate-y (-> Distance-Function Real Distance-Function))
(define ((rotate-y f θ) x y z)
  (f
   (+ (* (cos θ) x) (* (sin θ) z))
   y
   (+ (* (- (sin θ)) x) (* (cos θ) z))))

(: rotate-z (-> Distance-Function Real Distance-Function))
(define ((rotate-z f θ) x y z)
  (f
   (+ (* (cos θ) x) (* (- (sin θ)) y))
   (+ (* (sin θ) x) (* (cos θ) y))
   z))

(: union (-> Distance-Function * Distance-Function))
; union a variable number of shapes
(define ((union . fs) x y z)
  (apply min (map (λ ([f : Distance-Function]) (f x y z)) fs)))

(: intersection (-> Distance-Function * Distance-Function))
; intersection of a variable number of shapes
(define ((intersection . fs) x y z)
  (apply max (map (λ ([f : Distance-Function]) (f x y z)) fs)))

(: inverse (-> Distance-Function Distance-Function))
; flip inside with outside for a shape
; the surface of the shape stays the same
(define ((inverse f) x y z)
  (- (f x y z)))

(: difference (-> Distance-Function Distance-Function * Distance-Function))
; subtract shapes from another
(define ((difference f . fs) x y z)
  ((intersection f (inverse (apply union fs))) x y z))

(: extrude-z (-> Distance-Function Real Real Distance-Function))
; extrude a 2d shape along the z-axis,
; assuming that the 2d shapes are
; infinite along the z-axis
(define ((extrude-z f zmin zmax) x y z)
  (max (f x y z) (- zmin z) (- z zmax)))

(: repeat-1d (-> Distance-Function Real Distance-Function))
; repeat a shape infinitely along the x-axis
(define ((repeat-1d f d) x y z)
  (f (m:diff-nearest-mult x d) y z))

(: repeat-2d (-> Distance-Function Real Real Distance-Function))
; repeat a shape infinitely along the xy-plane
(define ((repeat-2d f d1 d2) x y z)
  (f (m:diff-nearest-mult x d1) (m:diff-nearest-mult y d2) z))

(: repeat-3d (-> Distance-Function Real Real Real Distance-Function))
; repeat a shape infinitely in 3 dimensions
(define ((repeat-3d f d1 d2 d3) x y z)
  (f (m:diff-nearest-mult x d1)
     (m:diff-nearest-mult y d2)
     (m:diff-nearest-mult z d3)))

(: repeat-polar (-> Distance-Function Integer Distance-Function))
; repeat a shape in a circle around the z-axis
(define ((repeat-polar f n) x y z)
  (match-let
      ([(vector x1 y1)
        (m:polar->cartesian
         (m:diff-nearest-mult (m:total-atan y x) (/ (* 2 pi) n))
         (sqrt (+ (sqr x) (sqr y))))])
    (f x1 y1 z)))

(: repeat-cylindrical (-> Distance-Function Integer Real Distance-Function))
; repeat a shape in a circle around the z-axis
; and linearly along the z-axis
(define ((repeat-cylindrical f n d) x y z)
  ((repeat-polar f n) x y (m:diff-nearest-mult z d)))

(: morph (-> Distance-Function Distance-Function Real Distance-Function))
; morph between two shapes by a percent
; n should be a number in [0, 1]
; FIXME: more restrictive type / contract would be better
(define ((morph f g n) x y z)
  (+ (* (f x y z) (- 1 n))
     (* (g x y z) n)))

(: scale (-> Distance-Function Real Distance-Function))
; scale a shape uniformly in 3 dimensions
(define ((scale f n) x y z)
  (let ([n (/ 1 n)])
    (f (* n x) (* n y) (* n z))))

(: taper (-> Distance-Function Nonnegative-Real Distance-Function))
; taper a 2d shape to a point
(define ((taper f h) x y z)
  (let ([n (/ (- h z) h)])
    (max (- 0 z)
         (- z h)
         ((scale f n) x y z))))

;;
;; Rendering
;;

(p:plot-width  600)
(p:plot-height 600)

; Takes a shape function and creates an interactive plot.
; Optional arguments:
;   - side length of the viewing cube
;   - number of samples per axis
;
; Example usage:
;   (render (circle 1))
;   (render (sphere 5) #:length 10)
;   (render (sphere 1) #:samples 100)
(: render (->* (Distance-Function)
               (#:length Positive-Integer #:samples Positive-Integer)
               Any)) ; FIXME: Needs actual return type
(define (render f #:length [l 2] #:samples [s 40])
  (let ([-l (/ (- l) 2)]
        [l  (/ l 2)])
    (p:plot3d
     (p:isosurface3d
      f
      0
      -l l -l l -l l
      #:samples s)
     #:altitude 25)))


