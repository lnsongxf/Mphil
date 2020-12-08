# Homework 5 - Ayagari model with aggregate risk: the Krusell-Smith algorithm

Repository for the homework 5 of Advanced Topics in Macro 1.

<img src="https://github.com/AdvancedTopicsInMacroI/problem-set-5-aisha-antonia/blob/main/comic.jpg?raw=true" width="500" align = "right">

## Team members :dancers:
Antonia Kurz and Aishameriane Schmidt.

## Requirements :computer:

Matlab R2019b.

## LaTeX report

See [here](https://github.com/AdvancedTopicsInMacroI/problem-set-5-aisha-antonia/blob/main/Homework_5_Adv_Topics_in_Macro_1___01122020.pdf).

## Remarks :exclamation:

We used the code from Maliar, Maliar and Valli (2010) as base code and changed accordingly. Changes were minor, though, and they are described in out final report.

## To-do list :dart:

- [X] Start repository
  - [X] Find a new comic strip
- [ ] *Zoom chat https://vu-live.zoom.us/j/95957600132 (Passcode: MacroLover)*
- [X] Create an Overleaf document: https://www.overleaf.com/project/5fbd262588690437eb8d2a82
- [X] Problem a 
  * Need to check if it is doing the log-linear forecasting rule **UPDATE**: It is
- [X] Problem b
  * Need to put the Euler errors **SEE BELOW**
- [X] Problem c
- [X] Problem d
  * How can we use higher precision in the non-stochastic simulation? **CHANGE `dN` to increase the number of points in the grid**
- [X] Overleaf
  - **AISHA** I can write for item (a) and (b) this evening, meanwhile you can get the EEE if this is ok for you. :)
 
## Resources :books:

- We have a [folder](https://github.com/AdvancedTopicsInMacroI/problem-set-5-aisha-antonia/tree/main/Background%20Reading) for the resources this time! 

## Open questions/discussion :fire: 

**Aisha**

- Code is rewritten with a notation that is more similar to what we had (but only the main file, not the functions);
- We can't use a Rouwenhorst/Tauchen method to generate shocks because we don't know how to get Q that will be compatible with the calibration.
- About specific items from the homework, see below some comments:
  - **Item a)** _Solve the model with the KS algorithm using the log-linear forecasting rule with the mean only and stochastic simulation_
    * The *log-linear forecasting rule* is already in there. This is in lines 228 until 235: you run a regression that is in the log of capital and see if the coefficients are getting closer from one iteration to the other. I don't know what she meant "mean only". I am inferring that this means using the mean of the distribution, not making the regression with only the intercept (which would not make much sense).
    
  - **Item b)** _Modify your algorithm to use non-stochastic simulation and compare the precision in terms of Euler Equation errors._
    * This is also implemented.
    * The method used for the non-stochastic simulation is **not** the one that we discussed in the lecture, which is based on [Young (2008)](http://www.wouterdenhaan.com/suite/finalversion-young.pdf). Young's method is based on the histogram to build gamma. However [Maliar, Maliar and Valli (2010)](https://github.com/AdvancedTopicsInMacroI/problem-set-5-aisha-antonia/blob/main/Background%20Reading/Malliar%2C%20Malliar%20and%20Valli%20(2008).pdf) use a different method - see footnote 5 on page 2. Young's method is implemented here: https://github.com/QuantEcon/krusell_smith_code/blob/f91757b08504c98e27b6a19aa2047d02f81cad57/KSfunctions.ipynb, in the section "Simulate path of aggregate capital", but this is Julia and adapting the method to the code we have would take a long time. More specifically, it would require changing the function AGGREGATE_NS.m, but I am not confident that they can be replaced so easily. I have the feeling that the Matlab code is already doing more stuff inside that function than the Julia code is doing. Then it would be necessary to find in the Julia code where the missing pieces are. Anyway, a job that would take many hours.
    * About the **EEE**, in the WP from [Elisabeth](https://github.com/AdvancedTopicsInMacroI/problem-set-5-aisha-antonia/blob/main/Background%20Reading/Proehl%20(2019).pdf) she explains how to compute on page 26. A similar thing appears in [Den Haan (2010)](https://github.com/AdvancedTopicsInMacroI/problem-set-5-aisha-antonia/blob/main/Background%20Reading/comparison.pdf) page 14. I have some questions on how to do this: 
      1. do we do this for the aggregate, considering the good and bad state separatel? 
      2. And if yes, in this case we need to take the series of aggregate mean capital (`kmalm` in the code) and compute what would be the implied `c`?
      3. How can we get the consumption choice implied by the explicitly calculated conditional expectation that both papers talk about? 

  - **Item c)** _Compute and plot the expected ergodic savings distribution_
    * In the slides there is no term as "ergodic savings distribution* which is super annoying since we have to compute something that we are not even given the definition.
    * BUT in the slides she calls the "a" as savings (capital savings)
    * Even though with this confusion in the notation, I think what is being asked is a plot of `k'` (since what you don't consume or put in production is investment and investment is equal to savings)
    * If a distribution is what is being asked, we need the savings (K') and the probabilities. I am just unsure how we get this probabilities. I have a hunch that it might be the term `kcross`, where we have the distribution for employed and unemployed. But this is just a educated guess.  
  - **Item d)** _Set the unemployment benefit rate to 0.65 and recompute the model solution. Choose the simulation method with higher precision in (b). Plot the expected ergodic distribution and compare to the base case._
    * I think this requires very little extra coding effort, once the other items are done we can try go for it. 
    * **UPDATE** Took 3h to compile in my laptop :D
