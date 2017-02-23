#lang typed/racket

(require (only-in plot/utils polar->cartesian))

(provide norm distance total-atan total-asin total-acos
         nearest-multiple diff-nearest-mult
         3d-cartesian->3d-polar polar->cartesian)

(: norm (-> Real * Nonnegative-Real))
(define (norm . xs)
  (sqrt (foldl + 0 (map sqr xs))))

(: distance (-> (Listof Real) (Listof Real) Nonnegative-Real))
(define (distance p1 p2)
  (apply norm (map - p1 p2)))

(: total-atan (-> Real Real Real))
(define (total-atan o a)
  (if (and (zero? o) (zero? a))
      0
      (atan o a)))

(: total-asin (-> Real Real Real))
(define (total-asin o h)
  (if (zero? h)
      0
      (asin (/ o h))))

(: total-acos (-> Real Real Real))
(define (total-acos a h)
  (if (zero? h)
      0
      (acos (/ a h))))

(: nearest-multiple (-> Real Real Real))
(define (nearest-multiple x y)
  (* y (round (/ x y))))

(: diff-nearest-mult (-> Real Real Real))
(define (diff-nearest-mult x y)
  (- x (nearest-multiple x y)))

(: 3d-cartesian->3d-polar (-> Real Real Real (Vector Real Real Real)))
(define (3d-cartesian->3d-polar x y z)
  (let* ([radius (sqrt (+ (sqr x) (sqr y) (sqr z)))]
         [rho    (total-asin z radius)]
         [theta  (total-asin y (* (cos rho) radius))])
    (vector theta rho radius)))
