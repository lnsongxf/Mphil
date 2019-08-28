#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
olsgen0.py

Purpose:
    To calculate the OLS estimates for a linear model.

Version:
    1       First start

Date:
    2019/08/28

Author:
    Aishameriane Venes Schmidt
"""
###########################################################
### Imports
import numpy as np
from bs3elim import *


# import pandas as pd
# import matplotlib.pyplot as plt

###########################################################
### mdX= fnGenX(iNobs, iLenbeta, dA, dB)
def fnGenX(iNobs, iLenbeta, dA, dB):
    """
    Purpose:
        To generate a matrix of observations considering the existence of an intercept

    Inputs:
        iNobs      integer, the number of observations
        iLenbeta   integer, the number of independent variables (or betas, including intercept)
        dA         double, the lowest bound for the uniform variable generating the X values
        dB         double, the highest bound for the uniform variable generating the X values

    Return value:
        mdX        matrix with doubles, of size iNobs x iLenbeta
    """
    mdX = np.zeros((iNobs, iLenbeta))
    mdX[:,0] = np.ones(iNobs)
    for i in range(1, iLenbeta):
        mdX[:, i] = np.random.uniform(dA, dB, iNobs)

    return mdX

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
### vdBetahat= fnBetahatMatrix(mdX, vdY)
def fnBetahatMatrix(mdX, vdY):
    """
    Purpose:
        To estimate Beta from Y = X Beta + Varepsilon using hat_beta = (X'X)"{-1} X'y

    Inputs:
        mdX      matrix of doubles, the matrix of observations
        vY       vector of doubles, the vector of the dependent variable

    Return value:
        vdBetahat vector of doubles, the estimate for Beta
    """
    vdBetahat = np.linalg.inv(mdX.transpose() @ mdX) @ mdX.transpose() @ vdY

    return vdBetahat

###########################################################
### main
def main():
    # Magic numbers
    vdBeta = np.array([1,2,3])
    dSigma = 0.25
    dMu    = 0
    dA     = 0
    dB     = 1
    iNobs  = 20
    
    # Initialisation
    vdBeta = vdBeta.reshape(-1,1)   
    iLenbeta = len(vdBeta)
    
    ## Generating X matrix
    mdX = fnGenX(iNobs, iLenbeta, dA, dB)
        
    ## Generating error vector
    vdEpsilon = fnGenError(iNobs, dMu, dSigma)
    
    ## Calculating the true Y = vdX @ vdBeta + vdEpsilon
    vdY = mdX @ vdBeta + vdEpsilon.reshape(-1,1)
    
    # Estimation 
    ## Estimating Betas using hat_beta = (X'X)^{-1} X'y
    vdBetahat_matrix = fnBetahatMatrix(mdX, vdY)
    
    ## Estimating Betas using elimination + backsubstitution
    mdC = np.hstack((mdX.transpose() @ mdX, mdX.transpose() @ vdY))
    ir  = ElimGauss(mdC)
    vdBetahat_backsubs = fnBacksubs1(mdC)     
    
    ## Estimating Betas using a package
    vdBetahat_package = np.linalg.lstsq(mdX, vdY, rcond = None)[0]

    # Output
    print ("The solution using the matricial solution is Beta^ =\n", vdBetahat_matrix, "\n")
    print ("The solution using the backsubstitution solution is Beta^ =\n", vdBetahat_backsubs, "\n")
    print ("The solution using the package solution is Beta^ =\n", vdBetahat_package, "\n")
###########################################################
### start main
if __name__ == "__main__":
    main()
