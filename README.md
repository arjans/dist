# Dist: 3d Modelling with Signed Distance Fields

Dist is a simple way to model 3d objects with signed distance fields. You can define functions representing shapes in Racket, and then render them in the repl using Racket's plot library. Here's a simple example of a shape function and its corresponding output in the repl:

```racket
(require dist)

(define ((my-sphere radius) x y z)
  (- (sqrt (+ (sqr x) (sqr y) (sqr z))) radius))

(render (my-sphere 1))

; =>
```
![alt sphere](/images/sphere.png)

The idea behind signed distance fields is simple: all shapes are represented by functions. Each function takes a point in 3d space and returns the smallest distance from that point to the surface of the shape it represents. (Points inside the shape have a negative distance.) All points that return 0 are on the surface of the shape. Rendering a shape then becomes rendering the isosurface of its distance field at 0. Here are some examples:

```racket
((my-sphere 1) 0 0 0) ; => -1
((my-sphere 1) 1 0 0) ; =>  0
((my-sphere 1) 1 1 1) ; =>  0.7320508075688772
```

## Installation

1. Download [Racket](https://download.racket-lang.org) - comes with the Dr. Racket IDE
2. Open Dr. Racket -> File -> Install package... -> `https://github.com/arjans/dist.git` -> Install
3. In the repl, first enter `(require dist)` then `(render (sphere 1))`

## What's possible?

Here's an upright for an FSAE car modelled with dist. The original model from Solidworks is given for comparison. See the code for this example in [/examples/upright.rkt](/examples/upright.rkt)

Dist                                              |  Solidworks
:------------------------------------------------:|:------------------------------------------------------------:
![alt upright in dist](/images/upright-dist.png)  |  ![alt upright in solidworks](/images/upright-solidworks.png)
