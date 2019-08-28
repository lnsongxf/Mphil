#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
bs0.py

Purpose:
    Manipulating matrices.

Version:
    1       First start
    2       Finished version

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
def bs0(mdA, vdB):
    """
    Purpose:
        Print a matrix and a vector as well as gives the maximum of the former and 
        the minimum of the latter.

    Inputs:
        mA      matrix with some doubles
        vB      vector with some doubles

    Return value:
        dMaxA   double, maximum element of A
        dMinB   double, minimum element of B
    """
    dMaxA = mdA.max()
    dMinB = vdB.min()

    return (dMaxA, dMinB)

###########################################################
### main
def main():
    # Magic numbers
    mdA = np.matrix('6.0, -2, 2, 4; 0, -4, 2, 2; 0, 0, 2, -5; 0, 0, 0, -3')
    vdB = np.array([16.0, -6, -9, -3])

    # Initialisation
    (dMaxA, dMinB) = bs0(mdA, vdB)

    # Output
    print ("Matrix A is equal to:\n", mdA, "\n")
    print ("Vector B is equal to:\n", vdB, "\n")
    print ("The maximum element of matrix A is equal to:", dMaxA, "\n")
    print ("The minimum element of vector B is equal to:", dMinB, "\n")

###########################################################
### start main
if __name__ == "__main__":
    main()
