#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
func.py

Purpose:
    Playing with functions

Version:
    1       First start

Date:
    2019/08/27

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
def fnPrint(argX, *args):
    """
    Purpose:
        Prints an argument and returns it to main()

    Inputs:
        argX      argX is something
        args      (optional) args can be something or a list of somethings

    Return value:
        [argX, args]    something, exactly the input
    """
    #####################################################
    # Question
    # The argument in here is not a known thing, could be anything in fact. 
    #So how do I concile with the hungarian notation?
    #####################################################
    dRes= argX

    for dA in args:
#        dRes= dRes + dA
         dRes = [dRes, dA]        
    
    return np.array(dRes)

###########################################################
### main
def main():
    # Magic numbers
    argX = 8.2
    argY = [[8.2], ["a"]]
    
    argA = 8.5
    argB = 7.5
    argC = 9.5

    # Initialisation
    resX = fnPrint(argX)
    resY = fnPrint(argY)
    resAB = fnPrint(argA, argB, argC)

    # Output
    print ("The argument is given by argX = ", resX)
    print ("The argument is given by argY = ", resY)
    print ("The argument is given by argAB = ", resAB)

###########################################################
### start main
if __name__ == "__main__":
    main()
