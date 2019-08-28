#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
empty.py

Purpose:
    ...

Version:
    1       First start

Date:
    YYYY/MM/DD

Author:
    zzz
"""
###########################################################
### Imports
import numpy as np
# import pandas as pd
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
    vX= [1, 2, 3]

    # Initialisation
    vX= np.array(vX)

    # Estimation
    dY= emptyfunc(vX)

    # Output
    print ("This is an almost empty program\n")
    print ("y= %g" % dY)

###########################################################
### start main
if __name__ == "__main__":
    main()
