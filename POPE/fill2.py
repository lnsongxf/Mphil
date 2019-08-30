#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
fill2.py

Purpose:
    Fill matrix mX= [i * j]

Version:
    0       First start, within main
    1       Now within a function, returning mX
    2       And through a pre-declared argument

Date:
    2019/08/29

@author: Aishameriane Venes Schmidt
"""
###########################################################
### Imports
import numpy as np
from fill1 import *
# import pandas as pd
# import matplotlib.pyplot as plt

###########################################################
### ArgXij(mX)
def ArgXij(mX):
    """
    ArgXij(mX)
    
    Purpose:
        Fill X by i*j, i= 1, .., iN, j= 1, .., iK
        
    Inputs:
        mX      iN x iK matrix, not filled

    Outputs:
        mX      iN x iK matrix, filled by i*j
    """
    iN = mX.shape[0]
    iK = mX.shape[1]
    for i in range(iK):
        mX[:, i] = np.random.rand(iN)
        
    return(mX)

###########################################################
### main
def main():
    # Magic numbers
    iN= 5
    iK= 3

    # Initialisation
    mX = RetXij(iN, iK)
    mX = ArgXij(mX)
    
    # Output
    print ("Output: mX=\n", mX)

###########################################################
### start main
if __name__ == "__main__":
    main()
