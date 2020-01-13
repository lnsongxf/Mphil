#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
mcPS.py

Purpose:
    To run a Monte Carlo experiment in Propensity Score with Stratification.
    Advanced Econometrics II - Block III - January 2020.

Version:
    1       First start
    2       Generating data ok
    3       Estimating probit and computing stuff ok
    

Date:
    2020/01/13

Author:
    Aishameriane Schmidt
    Ekaterina Ugulava
    Xu Lin
"""
###########################################################
### Imports
import numpy as np
from statsmodels.discrete.discrete_model import Probit
import pandas as pd
import matplotlib.pyplot as plt
import math
from scipy import stats

###########################################################
### mdX= fnGenX(iNobs, iLenbeta, dMu, dSigma)
def fnGenX(iNobs, iLenbeta, dMux, dSigmax):
    """
    Purpose:
        To generate a matrix of observations considering the existence of an intercept and columns with iid normal distributed values.

    Inputs:
        iNobs      integer, the number of observations
        iLenbeta   integer, the lenght of the parameter vector beta
        dMux       double, the mean for the normal distribution
        dSigmax    double, the standard deviation for the normal distribution
    Return value:
        mdX        matrix with doubles, of size iNobs x iLenbeta
    """
    mdX = np.zeros((iNobs, iLenbeta))
    mdX[:,0] = np.ones(iNobs)
    for i in range(1, iLenbeta):
        mdX[:, i] = np.random.normal(dMux, dSigmax, iNobs)

    return mdX
###########################################################
### vdEpsilon= fnGenError(iNobs, dMu, dSigma)
def fnGenError(iNobs, dMu, dSigma):
    """
    Purpose:
        To generate a vector of independent and identically distributed errors

    Inputs:
        iNobs             integer, the number of observations
        dMuepsilon        double, mean of the vector of errors
        dSigmaepsilon     double, standard deviation of the vector of errors

    Return value:
        vdEpsilon vector of doubles, the error vector
    """
    vdEpsilon = np.random.normal(0,1, iNobs)
    vdEpsilon = dMu + dSigma * vdEpsilon

    return vdEpsilon

###########################################################
### vdPstar = fnGenY(mdX, vdBeta, vdEpsilon)
def fnGenPstar(mdX, vdBeta, vdEpsilon):
    """
    Purpose:
        To generate a Pstar vector from vdPstar = mdX * vdBeta + vdEpsilon

    Inputs:
        mdX           matrix of doubles, the independent variables
        vdBeta        vector of doubles, the TRUE parameters of the model
        vdEpsilon     vector of doubles double, iid from a Normal distribution

    Return value:
        vdY          vector of doubles, the dependent variable vector
    """
    vdPstar = mdX.dot(vdBeta) + vdEpsilon.reshape(-1,1)

    return vdPstar

###########################################################
### vdD = fnGenTreat(vdPstar)
def fnGenTreat(vdPstar):
    """
    Purpose:
        To generate a vector with ones and zeros accordingly to vdPstar

    Inputs:
        vdPstar      vector with latent states

    Return value:
        viD          vector of integers, vdD[i] = 1 if vdPstar[i] <= 0
    """
    
    vdD = (vdPstar <= 0).astype(int)    
    
    return vdD
    
###########################################################
### vdY = fnGenY(vdD, vdDezinho, mdX, vdZeta, vdEta)
def fnGenY(vdD, vdDezinho, mdX, vdZeta, vdEta):
    """
    Purpose:
        To generate a Pstar vector from vdPstar = mdX * vdBeta + vdEpsilon

    Inputs:
        vdD           vector of booleans, the treatment dummy
        vdDezinho     true coefficient for the treatment
        mdX           matrix of doubles, the independent variables
        vdZeta        vector of doubles, the TRUE parameters of the model
        vdEta         vector of doubles double, iid from a Normal distribution

    Return value:
        vdY          vector of doubles, the dependent variable vector
    """
    vdY = vdD * vdDezinho + mdX.dot(vdZeta) + vdEpsilon.reshape(-1,1)

    return vdY
    
###########################################################
### main
def main():
    # Magic numbers
    dMux          = 0
    dSigmax       = 1
    dMuepsilon    = 0
    dSigmaepsilon = 1
    dMueta        = 0
    dSigmaeta     = 1
    iNobs         = 1000
    vdBeta        = np.array([1,2])
    vdZeta        = np.array([3,4])
    vdDezinho     = np.array([0])
    iSeed         = 6969
    iNgroups      = 11
    iIter         = 1000
    
    # Initialisation
    np.random.seed(iSeed)
    vdBeta    = np.array(vdBeta).reshape(-1,1)  
    vdZeta    = np.array(vdZeta).reshape(-1,1)
    iLenbeta  = len(vdBeta)
    
    # Start the iterations
    ## Create objects to store the ATE, variance, test statistics and R-Squares
    dvATE      = np.ones(iIter)
    dvVar      = np.ones(iIter)
    dvTtest    = np.ones(iIter)
    dvRsquared = np.ones(iIter)
    
    for i in range(iIter-1):  
        mdX       = fnGenX(iNobs, iLenbeta, dMux, dSigmax)
        iLenX     = mdX.shape[1]
        vdEpsilon = fnGenError(iNobs, dMuepsilon, dSigmaepsilon)
        vdPstar   = fnGenPstar(mdX, vdBeta, vdEpsilon)
        vdD       = fnGenTreat(vdPstar)
        vdEta     = fnGenError(iNobs, dMueta, dSigmaeta)
        vdY       = fnGenY(vdD, vdDezinho, mdX, vdZeta, vdEta)
    
        ## Create a dataframe with everything together
        ### This is not good because of the names, if we change the size of X then we need to manually change this, but I can check later how to make this better if needed 
        dfData = pd.DataFrame(np.hstack([vdY, vdD, mdX]), columns=['vdY', 'vdD', 'vdX1', 'vdX2']) 
        dfData["vdD"] = dfData["vdD"] == 1
        ### Can work out later in a better layout for these descriptives
        #print dfData.groupby('vdD').describe().unstack(1).reset_index() 
    
        # Estimation
        model = Probit(dfData['vdD'], dfData[dfData.columns[-mdX.shape[1]:]].copy())
        probit_model = model.fit()
        #print(probit_model.summary())
        dRsquare = probit_model.prsquared
        # Get the predicted probabilities    
        vdProbs = probit_model.predict(dfData[dfData.columns[-mdX.shape[1]:]].copy())
    
        ## Looking at the estimated probabilities
        #plt.figure(figsize=[10,8])
        #n, bins, patches = plt.hist(x=vdProbs, bins=8, color='#0504aa',alpha=0.7, rwidth=0.85)
        #plt.grid(axis='y', alpha=0.75)
        #plt.xlabel('Value',fontsize=15)
        #plt.ylabel('Frequency',fontsize=15)
        #plt.xticks(fontsize=15)
        #plt.yticks(fontsize=15)
        #plt.ylabel('Frequency',fontsize=15)
        #plt.title('Propensity Score Histogram',fontsize=15)
        #plt.show()
    
        ## Building the groups
        vdGroups = np.linspace(0,1,iNgroups)
        ## Putting back Y, treatment and the propensity score
        dfFinalData = pd.DataFrame(np.hstack([vdY, vdD, vdProbs.reshape(-1,1)]), columns = ['vdY', 'vdD', 'vdPS'])     
    
        #dfGroup1  = dfFinalData.loc[(dfFinalData['vdPS'] >= vdGroups[0]) & (dfFinalData['vdPS'] < vdGroups[1])]
        dfGroup2  = dfFinalData.loc[(dfFinalData['vdPS'] >= vdGroups[1]) & (dfFinalData['vdPS'] < vdGroups[2])]
        dfGroup3  = dfFinalData.loc[(dfFinalData['vdPS'] >= vdGroups[2]) & (dfFinalData['vdPS'] < vdGroups[3])]
        dfGroup4  = dfFinalData.loc[(dfFinalData['vdPS'] >= vdGroups[3]) & (dfFinalData['vdPS'] < vdGroups[4])]
        dfGroup5  = dfFinalData.loc[(dfFinalData['vdPS'] >= vdGroups[4]) & (dfFinalData['vdPS'] < vdGroups[5])]
        dfGroup6  = dfFinalData.loc[(dfFinalData['vdPS'] >= vdGroups[5]) & (dfFinalData['vdPS'] < vdGroups[6])]
        dfGroup7  = dfFinalData.loc[(dfFinalData['vdPS'] >= vdGroups[6]) & (dfFinalData['vdPS'] < vdGroups[7])]
        dfGroup8  = dfFinalData.loc[(dfFinalData['vdPS'] >= vdGroups[7]) & (dfFinalData['vdPS'] < vdGroups[8])]
        dfGroup9  = dfFinalData.loc[(dfFinalData['vdPS'] >= vdGroups[8]) & (dfFinalData['vdPS'] < vdGroups[9])]
        #dfGroup10 = dfFinalData.loc[(dfFinalData['vdPS'] >= vdGroups[9]) & (dfFinalData['vdPS'] < vdGroups[10])]
    
        #dMean1 = dfGroup1.groupby('vdD').mean().iloc[1, 0] - dfGroup1.groupby('vdD').mean().iloc[0, 0]
        dMean2 = (dfGroup2.groupby('vdD').mean().iloc[1, 0] - dfGroup2.groupby('vdD').mean().iloc[0, 0])*(dfGroup2.shape[0]/float(iNobs))
        dMean3 = (dfGroup3.groupby('vdD').mean().iloc[1, 0] - dfGroup3.groupby('vdD').mean().iloc[0, 0])*(dfGroup3.shape[0]/float(iNobs))
        dMean4 = (dfGroup4.groupby('vdD').mean().iloc[1, 0] - dfGroup4.groupby('vdD').mean().iloc[0, 0])*(dfGroup4.shape[0]/float(iNobs))
        dMean5 = (dfGroup5.groupby('vdD').mean().iloc[1, 0] - dfGroup5.groupby('vdD').mean().iloc[0, 0])*(dfGroup5.shape[0]/float(iNobs))
        dMean6 = (dfGroup6.groupby('vdD').mean().iloc[1, 0] - dfGroup6.groupby('vdD').mean().iloc[0, 0])*(dfGroup6.shape[0]/float(iNobs))
        dMean7 = (dfGroup7.groupby('vdD').mean().iloc[1, 0] - dfGroup7.groupby('vdD').mean().iloc[0, 0])*(dfGroup7.shape[0]/float(iNobs))
        dMean8 = (dfGroup8.groupby('vdD').mean().iloc[1, 0] - dfGroup8.groupby('vdD').mean().iloc[0, 0])*(dfGroup8.shape[0]/float(iNobs))
        dMean9 = (dfGroup9.groupby('vdD').mean().iloc[1, 0] - dfGroup9.groupby('vdD').mean().iloc[0, 0])*(dfGroup9.shape[0]/float(iNobs))
        #dMean10 = dfGroup10.groupby('vdD').mean().iloc[1, 0] - dfGroup10.groupby('vdD').mean().iloc[0, 0]
    
        dATE = dMean2 + dMean3 + dMean4 + dMean5 + dMean6 + dMean7 + dMean8 + dMean9
    
        # Add an extra column with the mean of the corresponding treatment or no treatment inside the same block
        dfGroup2['vdYmean'] = dfGroup2.groupby("vdD")["vdY"].transform('mean')
        dfGroup3['vdYmean'] = dfGroup3.groupby("vdD")["vdY"].transform('mean')
        dfGroup4['vdYmean'] = dfGroup4.groupby("vdD")["vdY"].transform('mean')
        dfGroup5['vdYmean'] = dfGroup5.groupby("vdD")["vdY"].transform('mean')
        dfGroup6['vdYmean'] = dfGroup6.groupby("vdD")["vdY"].transform('mean')
        dfGroup7['vdYmean'] = dfGroup7.groupby("vdD")["vdY"].transform('mean')
        dfGroup8['vdYmean'] = dfGroup8.groupby("vdD")["vdY"].transform('mean')
        dfGroup9['vdYmean'] = dfGroup9.groupby("vdD")["vdY"].transform('mean')
    
        # Take the difference between the individual Y and the average of the corresponding group (by treated and non-treated)
        dfGroup2['dvDiffSquared'] = (dfGroup2['vdY'] - dfGroup2['vdYmean'])**2
        dfGroup3['dvDiffSquared'] = (dfGroup3['vdY'] - dfGroup3['vdYmean'])**2
        dfGroup4['dvDiffSquared'] = (dfGroup4['vdY'] - dfGroup4['vdYmean'])**2
        dfGroup5['dvDiffSquared'] = (dfGroup5['vdY'] - dfGroup5['vdYmean'])**2
        dfGroup6['dvDiffSquared'] = (dfGroup6['vdY'] - dfGroup6['vdYmean'])**2
        dfGroup7['dvDiffSquared'] = (dfGroup7['vdY'] - dfGroup7['vdYmean'])**2
        dfGroup8['dvDiffSquared'] = (dfGroup8['vdY'] - dfGroup8['vdYmean'])**2
        dfGroup9['dvDiffSquared'] = (dfGroup9['vdY'] - dfGroup9['vdYmean'])**2
    
        # For each line, add the number of individuals in the same treatment (or no treatment) group
        dfGroup2['iSizeGroup'] = dfGroup2.groupby("vdD")["vdY"].transform('count')
        dfGroup3['iSizeGroup'] = dfGroup3.groupby("vdD")["vdY"].transform('count')
        dfGroup4['iSizeGroup'] = dfGroup4.groupby("vdD")["vdY"].transform('count')
        dfGroup5['iSizeGroup'] = dfGroup5.groupby("vdD")["vdY"].transform('count')
        dfGroup6['iSizeGroup'] = dfGroup6.groupby("vdD")["vdY"].transform('count')
        dfGroup7['iSizeGroup'] = dfGroup7.groupby("vdD")["vdY"].transform('count')
        dfGroup8['iSizeGroup'] = dfGroup8.groupby("vdD")["vdY"].transform('count')
        dfGroup9['iSizeGroup'] = dfGroup9.groupby("vdD")["vdY"].transform('count')
    
        # Divide the squared difference by the square of the size of the corresponding group
        dfGroup2['dvDiffSquaredDivided'] = dfGroup2['dvDiffSquared']/dfGroup2['iSizeGroup']**2
        dfGroup3['dvDiffSquaredDivided'] = dfGroup3['dvDiffSquared']/dfGroup3['iSizeGroup']**2
        dfGroup4['dvDiffSquaredDivided'] = dfGroup4['dvDiffSquared']/dfGroup4['iSizeGroup']**2
        dfGroup5['dvDiffSquaredDivided'] = dfGroup5['dvDiffSquared']/dfGroup5['iSizeGroup']**2
        dfGroup6['dvDiffSquaredDivided'] = dfGroup6['dvDiffSquared']/dfGroup6['iSizeGroup']**2
        dfGroup7['dvDiffSquaredDivided'] = dfGroup7['dvDiffSquared']/dfGroup7['iSizeGroup']**2
        dfGroup8['dvDiffSquaredDivided'] = dfGroup8['dvDiffSquared']/dfGroup8['iSizeGroup']**2
        dfGroup9['dvDiffSquaredDivided'] = dfGroup9['dvDiffSquared']/dfGroup9['iSizeGroup']**2
    
        # Sum the V term for treated and non-treated individuals and multiply by the size of the block divided by population squared
        dVGroup2 = (dfGroup2.groupby("vdD").sum().iloc[1, 5] + dfGroup2.groupby("vdD").sum().iloc[0, 5])*((dfGroup2.shape[0]/float(iNobs))**2)
        dVGroup3 = (dfGroup3.groupby("vdD").sum().iloc[1, 5] + dfGroup3.groupby("vdD").sum().iloc[0, 5])*((dfGroup3.shape[0]/float(iNobs))**2)
        dVGroup4 = (dfGroup4.groupby("vdD").sum().iloc[1, 5] + dfGroup4.groupby("vdD").sum().iloc[0, 5])*((dfGroup4.shape[0]/float(iNobs))**2)
        dVGroup5 = (dfGroup5.groupby("vdD").sum().iloc[1, 5] + dfGroup5.groupby("vdD").sum().iloc[0, 5])*((dfGroup5.shape[0]/float(iNobs))**2)
        dVGroup6 = (dfGroup6.groupby("vdD").sum().iloc[1, 5] + dfGroup6.groupby("vdD").sum().iloc[0, 5])*((dfGroup6.shape[0]/float(iNobs))**2)
        dVGroup7 = (dfGroup7.groupby("vdD").sum().iloc[1, 5] + dfGroup7.groupby("vdD").sum().iloc[0, 5])*((dfGroup7.shape[0]/float(iNobs))**2)
        dVGroup8 = (dfGroup8.groupby("vdD").sum().iloc[1, 5] + dfGroup8.groupby("vdD").sum().iloc[0, 5])*((dfGroup8.shape[0]/float(iNobs))**2)
        dVGroup9 = (dfGroup9.groupby("vdD").sum().iloc[1, 5] + dfGroup9.groupby("vdD").sum().iloc[0, 5])*((dfGroup9.shape[0]/float(iNobs))**2)
    
        # Compute the variance
        dVar = dVGroup2 + dVGroup3 + dVGroup4 + dVGroup5 + dVGroup6 + dVGroup7 + dVGroup8 + dVGroup9
    
        # Output
        #print ("ATE= %g" % dATE)
        #print ("Estimated Variance = %g" % dVar)
    
        # Compute the test statistic
        dTTest = dATE/(math.sqrt(dVar/iNobs))
        
        # Store results
        dvATE[i]      = dATE
        dvVar[i]      = dVar
        dvTtest[i]    = dTTest
        dvRsquared[i] = dRsquare
    
        # Report results
    
        pd.DataFrame(stats.describe(dvATE[:-1]))
 
###########################################################
### start main
if __name__ == "__main__":
    main()
