# Problem 1

## TO-DO

- [X] Overlaf (Aisha is on it)

## ANTONIA
- [x] Set up Tauchens Equivalent Gridspace Method
- [x] Set up Tauchens Importance Sampling Method
- [x] Set up Rouwenhorst's Method:
    - [x] Create P in terms of degrees of freedom (rows' sum =1)
    - [x] Get stationary distribution for each i
    - [X] Simulation
    - [x] Estimation of Parameters

## Aisha

I cleaned up a bit and implemented simulation for Tauchen's. I increased N to see if it seems ok, and the thing with importante sampling seems fine. The one with the Equidistant grid seems to have a way different standard deviation (try with N=1000). There is a small table at the end. I do have some ideas for the second method.

Rouwenhorst is working and also simulates, but **I am not confident on the way I made the grid.**

The averages (Table 1) seems a little off for the three methods.

## Some useful links

* [Tauchen’s method to approximate a continuous income process](http://www.fperri.net/TEACHING/macrotheory08/numerical.pdf)
* [Discretize AR(1) by Tauchen](https://discourse.quantecon.org/t/discretize-ar-1-by-tauchen/467)
* [Jan Hannes Lang's codes - Tauchen](https://sites.google.com/site/janhanneslang/programs)
* [A lot of codes](https://gist.github.com/sglyon/304d862b041b798d2a56)
* [Code for Rouwenhorst's method](https://sites.google.com/site/dlkhagva/computer-codes/matlab-codes-for-the-rouwenhorst-method)
