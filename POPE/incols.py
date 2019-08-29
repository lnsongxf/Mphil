#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
incols.py

Purpose:
    To have the necessary routines that olsgen3.py needs to run properly.

Version:
    1       First start

Date:
    2019/08/29

Author:
    Aishameriane Venes Schmidt
"""
###########################################################
### Imports
import numpy as np
from lib.bs3elim import *
from scipy import stats

# import pandas as pd
# import matplotlib.pyplot as plt

###########################################################
### mdX= fnGenX(iNobs, iLenbeta, dA, dB)
def fnGenX(iNobs, vdBeta, dA, dB):
    """
    Purpose:
        To generate a matrix of observations considering the existence of an intercept
        
    Inputs:
        iNobs      integer, the number of observations
        vdBeta     vector of doubles, the true parameters of the process
        dA         double, the lowest bound for the uniform variable generating the X values
        dB         double, the highest bound for the uniform variable generating the X values
        
    Return value:
        mdX        matrix with doubles, of size iNobs x iLenbeta
    """
    iLenbeta = len(vdBeta)
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
    vdY = mdX @ vdBeta + vdEpsilon.reshape(-1,1)

    return vdY

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
### (vdSBetas2, vdTBetas, vdPval) = fnDiagnostics(mdX, vdY, vdBetahat_matrix)
def fnDiagnostics(mdX, vdY, vdBetahat_matrix):
    """
    Purpose:
        Calculate standard error, t-values and p-values for the Betas
    Inputs:
        mdX                 matrix of doubles, the matrix of observations
        vY                  vector of doubles, the vector of the dependent variable
        vdBetahat_matrix    vector of doubles, the estimate for Beta
    Return value:
        vdSBetas2    vector of doubles, the estimate for the standard error for Beta^
        vdTBetas     vector of doubles, the t-value associated with Beta^
        vdPval       vector of doubles, the p-values for the t-values, assuming Beta = 0
    """
    ## Getting the number of observations
    iNobs = mdX.shape[0]
    
    ## Computing the error
    vdError = vdY - mdX @ vdBetahat_matrix
    
    ## Computing sigma^2
    iLenbeta = len(vdBetahat_matrix)
    dSigmahatsquared = (1/(iNobs-iLenbeta)) * vdError.T @ vdError
    
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


    # Initialisation


    # Estimation


    # Output
    print ("This is an almost empty program\n")


###########################################################
### start main
if __name__ == "__main__":
    main()
