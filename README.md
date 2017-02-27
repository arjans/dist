# dist
Exploring signed distance fields in Racket

This project is a way to easily experiment with signed distance fields, a representation for 3d shapes. You can define functions representing these signed distance fields in Racket, and then render them in the repl using Racket's plot library.

## Installation

1. Download [Racket](https://download.racket-lang.org) - comes with the Dr. Racket IDE
2. Open Dr. Racket -> File -> Install package... -> `https://github.com/arjans/dist.git` -> Install
3. In the repl, first enter `(require dist)` then `(render (sphere 1))`

## Demo

An upright for an FSAE car modelled with dist. The original model from Solidworks is given for comparison. See the code for this example in [/examples/upright.rkt](/examples/upright.rkt)

Dist                                              |  Solidworks
:------------------------------------------------:|:------------------------------------------------------------:
![alt upright in dist](/images/upright-dist.png)  |  ![alt upright in solidworks](/images/upright-solidworks.png)

## Usage
