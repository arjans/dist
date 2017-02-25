#lang typed/racket

(require (only-in plot/utils polar->cartesian))

(provide P P-x P-y P-z P-ρ P-θ P-ϕ
         total-atan total-asin total-acos
         nearest-multiple diff-nearest-mult
         polar->cartesian)

;;
;; Definition of 3d points
;;

(struct P ([x : Real] [y : Real] [z : Real]) #:transparent)

; radial distance
(: P-ρ (-> P Nonnegative-Real))
(define (P-ρ p)
  (sqrt (+ (sqr (P-x p)) (sqr (P-y p)) (sqr (P-z p)))))

; polar angle (from z-axis)
(: P-θ (-> P Real))
(define (P-θ p)
  (total-asin (P-z p) (P-ρ p)))

; azimuthal angle (on xy-plane)
(: P-ϕ (-> P Real))
(define (P-ϕ p)
  (total-asin (P-y p) (* (cos (P-θ p)) (P-ρ p))))

; project point onto z=n plane
(: project-z (-> P Real P))
(define (project-z p n)
  (match-let ([(P x y z) p])
    (P x y n)))

;;
;; Misc.
;;

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
