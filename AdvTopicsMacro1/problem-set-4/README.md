# Homework 4 - Ayagari model

Repository for the homework 4 of Advanced Topics in Macro 1.

<img src="https://www.smbc-comics.com/comics/1526483084-20180516.png" width="400" align = "right">

## Team members :dancers:
Antonia Kurz and Aishameriane Schmidt.

## Requirements :computer:

Matlab R2019b.

## LaTeX report

See [here](https://github.com/AdvancedTopicsInMacroI/problem-set-4-aisha-antonia/blob/main/Report_Aisha_Antonia_HW4.pdf).

## Remarks :exclamation:

We didn't manage to put much in the report, since our code was not working/giving meaningful results. Having more intermediate steps would be helpful.

## To-do list :dart:

- [X] Start repository
  - [X] Find a new comic strip
- [ ] *Zoom chat https://vu-live.zoom.us/j/95957600132 (Passcode: MacroLover)*
- [X] Create an Overleaf document: https://www.overleaf.com/project/5fb59549d45f5ba34c1b104d
- [:skull:] Problem 1 
- [:skull:] Problem 2
  
- [X] Overleaf
 
## Resources :books:

- [Chris Edmond](http://www.chrisedmond.net/phd2019.html) - See lectures 15-18 on incomplete markets 
- [C. Edmond notes on Ayagari's model](http://pages.stern.nyu.edu/~cedmond/406/N7B.PDF)
- [Andreas Müller](https://sites.google.com/site/mrandreasmueller/resources) - pdf and Matlab code for Ayagari's model
- [Cássio](https://github.com/cassioraa/Doc/tree/master/RCE) - This is a Python code from a friend of mine for Ayagari's model with two households. It is in Portuguese, though.
- [Ayagari's model in R](https://rstudio-pubs-static.s3.amazonaws.com/242273_5fc24214969c4ca79f96905571917dcf.html)
- [Denise](https://github.com/manfredinid/Matlab-Codes/blob/master/aiyagari_1994_SS_new.m) - This is a code from another friend, but she says she is not sure it is working properly.
- :new: [Quant Econ](https://python.quantecon.org/aiyagari.html) - Ayagari in Python
- :new: [Endogenous Grid Method notes](https://alisdairmckay.com/Notes/HetAgents/EGM.html)
- :new: [Endogenous grid Method](http://luowenlan.weebly.com/files/theme/slides0918.pdf) - check slide 16
 
## Open questions/discussion :fire: 

## Draft of matlab codes :computer:
    
needed:
na = number of gridpoints for asset position a', a(k)
ny = number of gridpoints for possible y(j)
    
### a)Set the interest rate to 0.04,the wage to 1,
    R = 1.04;
    w = 1;
  and solve the household’s income-fluctuation problem. 
  Use both piecewise-linear interpolation 
  and the endogenous-grid method for policy-function iteration

  Super nice stepwise: https://www.cemfi.es/~pijoan/download/notes-on-endogenous-grid-method.pdf
  Sol: 
    endogenous-grid method/Piecewise linear interpolation:
    
   1. get Euler equation
   2. analytically with 1. write policy function for c as function: c(a',y)
   
   **(here starts the actual coding then:)**
    
   3. create a grid on a':
        a(1) = alow;
        make gridpoints 2:na
   4. (out: Y, Gamma, gamma, ...; in: ny, na, y, ...)
      - set up Y as grid of y (chose grid with length n)
      - get Gamma via Rouwenhorst? (It's the transition matrix, right?)
      - get gamma^T via Eigenvector for Gamma (slide 13)
   5.  policy function for c as function: c(a',y), given Gamma: 
      - c(k,j) becomes matrix: na x ny 
      - (OR write is only as function c = @(a,y) function;)
   6. Using the budget constraint, we COULD recover the initial assets a(i,j)
      - for a household with shock y_j that led him to take choices a' = a(i) and c(a(i),y(j)):
          - a(i) + c(i, j) = a'inv(i,j)* R + n*y(j)*w;
      - (a'inv = function to get the asset today which would lead to asset a(i) tomorrow)
        but: n is endogeneous (labour supply)
   7. Write n as function: n(i,y) is matrix with na x ny 
      - -> from n(a_i,y_j) via the intratemporal condition: u_n(c, n) = w*y*u_c(c, n)
   8. We may wanna switch 6. & 7. :), but with 6 & 7, we get:
       - Grid A(j) is a vector of all possible a we could have started from
   9. repeat algorithm at 5 with new grid A given shock j
    
   - for endogenous grid, policy function for c needs to be updated (see pdf).
    (Sebastian used VFI)
    
   - this might be an even better source to set it up: http://pages.stern.nyu.edu/~dbackus/Computation/Violante%20endogenous%20grid.pdf
   
### b) Compute the steady state of this economy. 
    
 ### for problem 2 (other file), General Equilibrium and Calibration
   a) Compute the interest rate and wage that constitute a stationary general equilibrium.
    
   GENERAL Algorithm: see slide 11:
    - fix r0=0.04, w=1
    - need a'(a,y; r0) via policy function (question a))
    - get transition function Gamma and calculate stationary distribution lambda (question b))
    - use lambda to calc A(r0)
    - use nonlinear equation solver to update r, go back to start
    
   (BONUS: b) Find the discount factor, and a total factor productivity )
    that yield an equilibrium with a wealth-to-outputratio of 2.5,
    and output equal to 1.
    Otherwise use the same parameters described above.
