#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
olssa0.py

Purpose:
    To read data from US price index out of a csv file, calculate inflation, split data, make seasonal dummies, run a regression and plot results/diagnostics

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
import pandas as pd

# import matplotlib.pyplot as plt

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
    
    dfInflation = pd.read_csv("//vu.local/home/ast323/Documents/Principles of programming/Tutorial 0/Assign/OLS SA/sa0_180827.csv")
    
    # Initialisation
    ## Getting to know the dataframe
    dfInflation.shape # rows and columns
    iR = dfInflation.shape[0]
    iC = dfInflation.shape[1]
    
    

    # Estimation


    # Output
    print ("This is an almost empty program\n")

###########################################################
### start main
if __name__ == "__main__":
    main()
