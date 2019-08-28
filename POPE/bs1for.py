#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
bs1for.py

Purpose:
    Count backwards using a for-loop. I think this is already what is needed in bs2solve.py.

Version:
    1       First start
    2       Counting backwards using a for-loop

Date:
    2019/08/28

Author:
    Aishameriane Venes Schmidt
"""
###########################################################
### Imports
import numpy as np
# import pandas as pd
# import matplotlib.pyplot as plt

###########################################################
### dY= emptyfunc(vX)
def fnBacksubs(mdA, vdB):
    """
    Purpose:
        To make the backsubstitution to solve the system Ax = b

    Inputs:
        mdA     matrix with doubles
        vdB     vector with doubles

    Return value:
       vX       vector with doubles, solution to Ax = b
    """
    
    iN = len(vdB)
    vX  = np.zeros_like(vdB)
    
    for i in range(iN - 1, -1, -1):
        dS = fnCalcSum(mdA, vX, i)
        vX[i] = (vdB[i] - dS)/mdA[i,i]
        
    return(vX)
###########################################################
### dY= emptyfunc(vX)
def fnCalcSum(mdA, vX, i):
    """
    Purpose:
        Calculate the sum given by sum_j>i {a_ij \times x_j}

    Inputs:
        mdA     matrix with doubles
        vX      vector with doubles
        i       the index for the for loop

    Return value:
       
    """
    iN = len(vX)
    dS = 0
    for j in range(i+1, iN):
        dS = dS + mdA[i,j] * vX[j]

    return (dS)

###########################################################
### main
def main():
    # Magic numbers
    mdA = np.array([[6.0, -2, 2, 4], [0, -4, 2, 2], [0, 0, 2, -5], [0, 0, 0, -3]])
    vdB = np.array([16.0, -6, -9, -3])
    
    # Initialisation
    vdB = vdB.reshape(-1,1)
    
    
    # Estimation
#    vX[i] = (vdB[i] - dS)/mdA[i,i]
    
    # Output
    vX = fnBacksubs(mdA, vdB)
    
    print("Matrix A is given by: \n", mdA, "\n")
    print("Vector b is given by: \n", vdB, "\n")
    print("The solution of the system Ax=b is given by x= \n", vX, "\n")
    print("Indeed this is a solution because Ax= \n", mdA@vX, "\n")

###########################################################
### start main
if __name__ == "__main__":
    main()
