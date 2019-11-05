#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
HW1_adveconometrics.py

Purpose:
    To solve exercise 4 from the problem set.
Version:
    1       First start

Date:
    2019/11/05

Author:
    Aishameriane Venes Schmidt
    Paloma de Melo Assunção
"""

###########################################################
### Imports
import numpy as np
import pandas as pd
import math as math
import statistics as stats

# import matplotlib.pyplot as plt
###########################################################
###########################################################
### main
def main():
    # Magic numbers
    ## Sample size and replications
    iSampleSize = np.array([10,25,100,500])
    iRep        = 1000
    ## Parameters of the distributions
    dMu      = 0
    dSigma2  = 1
    dDF      = 2
    iND      = 2 # number of distributions
    ## Set a seed for replicability
    np.random.seed(6969)
    
    ## Empty vectors to store mean, median, and non-centered sample standard deviation
    vdNormalMean   = np.empty([len(iSampleSize), iRep])
    vdNormalMedian = np.empty([len(iSampleSize), iRep])
    vdTMean        = np.empty([len(iSampleSize), iRep])
    vdTMedian      = np.empty([len(iSampleSize), iRep])
    vdSampleSD     = np.empty([2*len(iSampleSize), iND])
    vdSampleSD2     = np.empty([2*len(iSampleSize), iND])
    
    # Initialisation
    ## First item, part 1
    for i in range(0, len(iSampleSize)):
        for j in range(0, iRep):
            vdNormal = np.random.normal(dMu, dSigma2, iSampleSize[i])
            vdNormalMean[i, j]   = stats.mean(vdNormal)
            vdNormalMedian[i, j] = stats.median(vdNormal)
            vdT = np.random.standard_t(dDF, iSampleSize[i])
            vdTMean[i, j]   = stats.mean(vdT)
            vdTMedian[i, j] = stats.median(vdT)
    
    ## Sample standard deviation and JB statistics for each sample size and each distribution
    for i in range(0,len(iSampleSize)):
        vdSampleSD2[i,0]     =  math.sqrt((np.sum(np.square(vdNormalMean[i,:])))/(iRep-1))
        vdSampleSD2[(i+4),0] =  math.sqrt((np.sum(np.square(vdNormalMedian[i,:])))/(iRep-1))
        vdSampleSD2[i,1]     =  math.sqrt((np.sum(np.square(vdTMean[i,:])))/(iRep-1))
        vdSampleSD2[(i+4),1] =  math.sqrt((np.sum(np.square(vdTMedian[i,:])))/(iRep-1))
    
    # For the histograms
    # https://stackoverflow.com/questions/29530355/plotting-multiple-histograms-in-grid
    
    # For the Jarque Bera
    # https://docs.scipy.org/doc/scipy/reference/generated/scipy.stats.jarque_bera.html
    
    
    
    
    