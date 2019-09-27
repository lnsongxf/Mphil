# Exercise GARCH

## Toy model

  * First generate data from a pure GARCH model and estimate the parameters:
      * \theta = (\beta', \omega, \alpha, \delta)' = (1, .05, .05, .9)'
      * This data should have mean \mu = 1
      * The data should also have unconditional variance \sigma^2 = \E[\sigma^2_t] = \frac{\omega}{1-\alpha-\delta}
      * Use T = 5000 observations and compare your estimates to the true parameters.
  * Create a function `GetGARCH()`
      * Constructs the vector of variances given the parameters and the data
      * Can it reconstruct (exactly) the vS2 that was generated? _(what does this means?)_
      * Build a new `AvgLnLiklGARCHM()`, using old code for the regression, and your `GetGARCH()`, to construct vLL and the average loglikelihood.
      * Optimise... Maybe compare outcomes of optimisation of regression only, or of GARCH-M?
          
## Inputs

### Preparing the data

sa0_180827.csv: price index (P-t)

* Construct the inflation rate using:

y_t = 100(log(Pt)-log(P_{t-1})

* Make the explanatory variables with

* 11 seasonal dummies (one for each month)
* 5 level shift dummies (that from a specific point onwards become 1):
    * 1973:3
    * 1976:7
    * 1979:1
    * 1982:7
    * 1990:1
    
## Restrictions on the parameters

* Ensure \omega, \alpha, \delta > 0;
* \delta + \alpha < 1 (non-explosive).

* We can use the SQP approach:
    * It appears to be sufficient to impose:
        * \omega > 0
        * 0 < \alpha < 1
        * 0 < \delta < 1
    * Failure (return 0) if the sum of \alpha and \delta is too large (what is too large?)

## What to deliver?

   * A program that:
       * Estimates the model;
       * Gives the parameter output includind standard deviations;
       * Returns the optimal loglikelihood;
       * Returns the number of iterations used to optimize.
     
   * Repeat the procedure for these three models:
       * The pure regression model (without GARCH effects);
       * The pure GARCH model (without mean effect, i.e., set \mu_t = \beta_0 constant)
       * The full GARCH-M model, estimating full \theta = (\beta', \omega, \alpha, \delta)'
        
   * Provide graphical outputs:
       * Plot inflation y_t with the estimated mean process \mu_t
       * Plot the standard deviation \sigma_t or variance \sigma_t^2
       * Compare de density plots of:
             * y_t
             * \alpha_t = y_t - \mu_t
             * \epsilon_t = \frac{\alpha_t}{\sigma_t}
         * Which one seems to be normally distributed?
     
   * Provide a shor report (max 5 pages excluding graphs/tables)
       * Discuss the findings
       * Problems encountered
       * Other comments
        
 ZIP everything and submit on canvas ready-to-run Python prorams with the data. If necessary add a readme.txt to run in a specific order.
 
## Things that might be useful

    * The OLS exercise from class
    * The slides from the exercises (has the correct form of the likelihood)
