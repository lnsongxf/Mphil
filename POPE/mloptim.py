#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
mloptim.py

Purpose:
    To estimate the parameters of a linear regression model using maximum likelihood.

Version:
    1       First start

Date:
    2019/08/30

Author:
    Aishameriane Venes Schmidt
"""
###########################################################
### Imports
import numpy as np
import pandas as pd
# import matplotlib.pyplot as plt

###########################################################
### mdX= fnGenX(iNobs, vBeta)
def fnGenX(iNobs, vBeta):
    """
    Purpose:
        To generate a matrix of observations considering the existence of an intercept
    
    Inputs:
        iNobs      integer, the number of observations
        vBeta      vector of doubles, the vector with the Betas

    Return value:
        mdX        matrix with doubles, of size iNobs x iLenbeta
    """
    
    iLenbeta = vBeta.shape[0]
    mdX = np.zeros((iNobs, iLenbeta))
    mdX[:,0] = np.ones(iNobs)   # Intercept
    
    for i in range(1, iLenbeta):
        mdX[:, i] = np.random.uniform(0, 1, iNobs)

    return pd.DataFrame(mdX)

###########################################################
### vdEpsilon= fnGenError(iNobs, dMu, dSigma)
def fnGenError(iNobs, dMu, dSigma):
    """
    Purpose:
        To generate a vector of independent and identically distributed errors
    Inputs:
        iNobs      integer, the number of observations
        dMu        double, mean of the vector of errors
        dSigma     double, standard deviation of the vector of errors
    Return value:
        vdEpsilon vector of doubles, the error vector
    """
    vdEpsilon = np.random.normal(0,1, iNobs)
    vdEpsilon = dMu + dSigma * vdEpsilon

    return vdEpsilon

###########################################################
### vdY = fnGenY(mdX, vdBeta, vdEpsilon)
def fnGenY(mdX, vdBeta, vdEpsilon):
    """
    Purpose:
        To generate a Y vector from vY = mdX * vdBeta + vdEpsilon

    Inputs:
        mdX           matrix of doubles, the independent variables
        vdBeta        vector of doubles, the TRUE parameters of the model
        vdEpsilon     vector of doubles double, iid from a Normal distribution

    Return value:
        vdY          vector of doubles, the dependent variable vector
    """
    vdY = mdX @ vdBeta + vdEpsilon

    return vdY

###########################################################
### dAvgLogLike= fnAvgLogLikeReg(vdY, mdX, vdP)
def fnAvgLogLikeReg(vdY, mdX, vdP):
    """
    Purpose:
        Provide the loglikelihood function for a linear regression model.

    Inputs:
        vdY      vector of dependent variable
        mdX      matrix of regressors, including intercept
        vdP      vector of parameters

    Return value:
        dAvgLogLike      double, the average loglikelihood
    """
    
    (iNobs, iK) = mdX.shape
    if (np.size(vdP) != iK + 1):
        print ("Warning, wrong size of parameter vector vdP =", vdP)
        
    (dSigma, vdBeta) = (vdP[0], vdP[1:])
    
    vdEpsilon = vdY - mdX @ vdBeta
    vAvgLogLike = -0.5* (np.log(2*np.pi) + 2* np.log(dSigma) + np.square(vdEpsilon/dSigma))
    dAvgLogLike = np.sum(vAvgLogLike, axis = 0)

    return dAvgLogLike

###########################################################
### dY= emptyfunc(vX)
def emptyfunc(vX):
    """
    Purpose:
        Provide an example of a function declaration, with comments

    Inputs:
        vX      iX vector of data

    Return value:
        dY      double, in this case 42.0
    """
    dY= 42.0

    return dY

###########################################################
### main
def main():
    # Magic numbers
    vdBeta  = [1, 1, 1]
    
    if type(vdBeta) == list:
        vdBeta = np.array(vdBeta)
    
    iNobs  = 10
    dSigma = 1.2
    dMu    = 0
    iSeed  = 6969
    
    # Initialisation
    np.random.seed(iSeed)

    mdX       = fnGenX(iNobs, vdBeta)
    vdEpsilon = fnGenError(iNobs, dMu, dSigma)
    vdY       = fnGenY(mdX, vdBeta, vdEpsilon)
    vdP       = np.append(dSigma, vdBeta)  # We are not estimating Mu
    
    # Estimation
    dAvgLogLike= fnAvgLogLikeReg(vdY, mdX, vdP)
    
    ## Testing if the likelihood is right
    #    This is to check whether the Average log likelihood is good or not
#    We maintain the Y and X but use a different Beta, so if the value is higher, then 
    vdBeta  = [100, 100, 100] 
    if type(vdBeta) == list:
        vdBeta = np.array(vdBeta)
    
    vdP       = np.append(dSigma, vdBeta)
    
    dAvgLogLike_test = fnAvgLogLikeReg(vdY, mdX, vdP)
    print("The average log likelihood with the correct Beta is:", np.around(dAvgLogLike,4), "\n") 
    print("The average log likelihood with the wrong Beta is:",   np.around(dAvgLogLike_test,4), "\n")

    # Output
#    print ("This is an almost empty program\n")
#    print ("y= %g" % dY)

###########################################################
### start main
if __name__ == "__main__":
    main()
