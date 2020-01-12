#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
mcPS.py

Purpose:
    To run a Monte Carlo experiment in Propensity Score with Stratification.
    Advanced Econometrics II - Block III - January 2020.

Version:
    1       First start

Date:
    2020/01/12

Author:
    Aishameriane Schmidt
    Ekaterina Ugulava
    Xu Lin
"""
###########################################################
### Imports
import numpy as np
# import pandas as pd
# import matplotlib.pyplot as plt

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
        mdX[:, i] = np.random.uniform(dMux, dSigmax, iNobs)

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
    dMux          = 0
    dSigmax       = -1
    dMuepsilon    = 0
    dSigmaepsilon = 1
    dMueta        = 0
    dSigmaeta     = 1
    iNobs         = 10
    vdBeta        = np.array([1,2])
    vdZeta        = np.array([3,4])
    vdDezinho     = np.array([0])
    iSeed         = 6969
    
    # Initialisation
    np.random.seed(iSeed)
    vdBeta    = np.array(vdBeta).reshape(-1,1)  
    vdZeta    = np.array(vdZeta).reshape(-1,1)
    iLenbeta  = len(vdBeta)
    mdX       = fnGenX(iNobs, iLenbeta, dMux, dSigmax)
    vdEpsilon = fnGenError(iNobs, dMuepsilon, dSigmaepsilon)
    vdPstar   = fnGenPstar(mdX, vdBeta, vdEpsilon)
    vdD       = fnGenTreat(vdPstar)
    vdEta     = fnGenError(iNobs, dMueta, dSigmaeta)
    vdY       = fnGenY(vdD, vdDezinho, mdX, vdZeta, vdEta)

    # Estimation
    

    # Output
    print ("This is an almost empty program\n")
    print ("y= %g" % dY)

###########################################################
### start main
if __name__ == "__main__":
    main()
