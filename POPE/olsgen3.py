#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
olsgen3.py
Purpose:
    To calculate the OLS estimates for a linear model.
Version:
    1       First start
    2       Finished (except for the last uni-dimensional part)
    3       Starting to add stuff from day 2
    4       Moved to next exercise
Date:
    2019/08/28, 2019/08/29
Author:
    Aishameriane Venes Schmidt
"""
###########################################################
### Imports
import numpy as np
from scipy import stats
import pandas as pd
# import matplotlib.pyplot as plt

# Import module with olsgen3 functions
from lib.incols import *

###########################################################
### main
def main():
    # Magic numbers
    vdBeta = [1,2,3]
    dSigma = 0.25
    dMu    = 0
    dA     = 0
    dB     = 1
    iNobs  = 20
    iSeed  = 6969
    
    # Initialisation
    np.random.seed(iSeed)
    vdBeta = np.array(vdBeta).reshape(-1,1)   
#    vdBeta = np.array(vdBeta) ## TRY TO WORK THIS OUT LATER ON
    iLenbeta = len(vdBeta)
    
    ## Generating X matrix
    mdX = fnGenX(iNobs, vdBeta, dA, dB)
        
    ## Generating error vector
    vdEpsilon = fnGenError(iNobs, dMu, dSigma)
    
    ## Calculating the true Y = vdX @ vdBeta + vdEpsilon
    vdY = fnGenY(mdX, vdBeta, vdEpsilon)
#    print ("shape of vy=", vdY.shape)
    
    # Estimation 
    ## Estimating Betas using hat_beta = (X'X)^{-1} X'y
    vdBetahat_matrix = fnEstimateMM(mdX, vdY)
    
    ## Estimating Betas using elimination + backsubstitution
    vdBetahat_backsubs =  fnEstimateEB(mdX, vdY)    
    
    ## Estimating Betas using a package
    vdBetahat_package = fnEstimatePF(mdX, vdY)
    
    # Diagnostics
    (vdSBetas2, vdTBetas, vdPval) = fnDiagnostics(mdX, vdY, vdBetahat_matrix)
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