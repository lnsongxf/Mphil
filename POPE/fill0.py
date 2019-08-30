#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
fill0.py

Purpose:
    Fill matrix mdX= [i * j]

Version:
    0       First start, within main

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
### main
def main():
    # Magic numbers
    iN = 5
    iK = 3
    iSeed  = 6969
    
    # Initialisation
    np.random.seed(iSeed)
    
    ## First try, make X on main()
    mdX = np.zeros((iN, iK))
    for i in range(iK):
        mdX[:, i] = np.random.uniform(0, 1, iN)

    # Output
    print ("Output: mX=\n", mdX)

###########################################################
### start main
if __name__ == "__main__":
    main()
