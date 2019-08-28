#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
olsgen0.py

Purpose:
    To calculate the OLS estimates for a linear model.

Version:
    1       First start
    2       Finished (except for the last uni-dimensional part)

Date:
    2019/08/28

Author:
    Aishameriane Venes Schmidt
"""
###########################################################
### Imports
import numpy as np
from bs3elim import *
from scipy import stats
import pandas as pd
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
### vdBetahat= fnEstimateMM(mdX, vdY)
def fnEstimateMM(mdX, vdY):
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
### vdBetahat= fnEstimateEB(mdX, vdY)
def fnEstimateEB(mdX, vdY):
    """
    Purpose:
        To estimate Beta from Y = X Beta + Varepsilon using backsubstitution available in previous codes

    Inputs:
        mdX      matrix of doubles, the matrix of observations
        vY       vector of doubles, the vector of the dependent variable

    Return value:
        vdBetahat vector of doubles, the estimate for Beta
    """
    mdC = np.hstack((mdX.transpose() @ mdX, mdX.transpose() @ vdY))
    ir  = ElimGauss(mdC)
    vdBetahat = fnBacksubs1(mdC)  
    
    return vdBetahat

###########################################################
### vdBetahat= fnEstimatePF(mdX, vdY)
def fnEstimatePF(mdX, vdY):
    """
    Purpose:
        To estimate Beta from Y = X Beta + Varepsilon using a built-in numpy function

    Inputs:
        mdX      matrix of doubles, the matrix of observations
        vY       vector of doubles, the vector of the dependent variable

    Return value:
        vdBetahat vector of doubles, the estimate for Beta
    """
    vdBetahat = np.linalg.lstsq(mdX, vdY, rcond = None)[0]  
    
    return vdBetahat

###########################################################
### (vdSBetas2, vdTBetas, vdPval) = fnDiagnostics(mdX, vdY, vdBetahat_matrix, iNobs)
def fnDiagnostics(mdX, vdY, vdBetahat_matrix, iNobs):
    """
    Purpose:
        To estimate Beta from Y = X Beta + Varepsilon using a built-in numpy function

    Inputs:
        mdX                 matrix of doubles, the matrix of observations
        vY                  vector of doubles, the vector of the dependent variable
        iNobs               integer, number of observations
        vdBetahat_matrix    vector of doubles, the estimate for Beta

    Return value:
        vdSBetas2    vector of doubles, the estimate for the standard error for Beta^
        vdTBetas     vector of doubles, the t-value associated with Beta^
        vdPval       vector of doubles, the p-values for the t-values, assuming Beta = 0
    """
    ## Computing the error
    vdError = vdY - mdX @ vdBetahat_matrix
    
    ## Computing sigma^2
    iLenbeta = len(vdBetahat_matrix)
    dSigmahatsquared = (1/(iNobs-iLenbeta))*sum(vdError**2)
    
    ## Computing Sigma
    mdSigma = dSigmahatsquared * np.linalg.inv(mdX.transpose() @ mdX)
    
    ## Computing the t statistics
    ### First, we get the s value of each one using a lambda function
    vdSBetas2 = [mdSigma[i,i] for i in range(iLenbeta)]
    
    ### Now we compute the t-values
    vdTBetas = [vdBetahat_matrix[i] / np.sqrt(np.array(vdSBetas2))[i] for i in range(iLenbeta)]
    
    ### Finally, we discover the probabilities of finding those results assuming Beta = 0
    vdPval = stats.t.sf(np.abs(vdTBetas), iNobs-iLenbeta)*2  # two-sided pvalue = Prob(abs(t)>tt)  
    
    return (vdSBetas2, vdTBetas, vdPval)

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
    vdBetahat_matrix = fnEstimateMM(mdX, vdY)
    
    ## Estimating Betas using elimination + backsubstitution
    vdBetahat_backsubs =  fnEstimateEB(mdX, vdY)    
    
    ## Estimating Betas using a package
    vdBetahat_package = fnEstimatePF(mdX, vdY)
    
    # Diagnostics
    (vdSBetas2, vdTBetas, vdPval) = fnDiagnostics(mdX, vdY, vdBetahat_matrix, iNobs)
    vdSBetas2 = np.array(vdSBetas2).reshape(-1,1) 
    vdTBetas  = np.array(vdTBetas) 
       
    # Output
    print ("The solution using the matricial solution is Beta^_1 =\n", vdBetahat_matrix, "\n")
    print ("The solution using the backsubstitution solution is Beta^_2 =\n", vdBetahat_backsubs.reshape(-1,1), "\n")
    print ("The solution using the package solution is Beta^_3 =\n", vdBetahat_package, "\n")
    print ("The three solutions are virtually the same because Beta^_1 - Beta^_2 =\n", np.around(vdBetahat_matrix - vdBetahat_backsubs.reshape(-1,1),2), "\n and Beta^_2 - Beta^_3 =\n", np.around(vdBetahat_backsubs.reshape(-1,1)-vdBetahat_package,2))
    mRes = np.hstack([np.around(vdBetahat_matrix,2), np.around(vdSBetas2,2), np.around(vdTBetas,2), np.around(vdPval,5)]) 
    print ("Estimation results : ")
    print (pd.DataFrame(mRes , columns =[ 'b', 's(b)', 't', 'p-value']))

###########################################################
### start main
if __name__ == "__main__":
    main()