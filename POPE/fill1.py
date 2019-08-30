#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
fill1.py

Purpose:
    Fill matrix mX= [i * j]

Version:
    0       First start, within main
    1       Now within a function, returning mX

Date:
    2019/08/29

@author: Aishameriane Venes Schmidt
"""
###########################################################
### Imports
import numpy as np
# import pandas as pd
# import matplotlib.pyplot as plt

###########################################################
### mX= RetXij(iN, iK)
def RetXij(iN, iK):
    """
    mX= RetXij(iN, iK)
    
    Purpose:
        Fill X by i*j, i= 1, .., iN, j= 1, .., iK
        
    Inputs:
        iN, iK  integers, row and column size
        
    Return value:
        mX      iN x iK matrix
    """
    mX = np.zeros((iN, iK))
    
    return mX    

###########################################################
### main
def main():
    # Magic numbers
    iN= 5
    iK= 3

    # Initialisation
    mX= RetXij(iN, iK)
    
    # Output
    print ("Output: mX=\n", mX)

###########################################################
### start main
if __name__ == "__main__":
    main()
