#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
argument.py

Purpose:
    To play with arguments inside functions

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
import math as math
# import pandas as pd
# import matplotlib.pyplot as plt

###########################################################
### dY= emptyfunc(vX)
def fnSquare(dX):
    """
    Purpose:
        Square a double

    Inputs:
        dX      double, the number to be squared

    Return value:
        dY      dX ** 2
        dZ      math.pow(dX, 2)
    """
    dY = dX ** 2
    dZ = math.pow(dX, 2)
#    print(dY)
#    print(dZ)

    return (dY, dZ)

###########################################################
def fnReplacing_1(lsX):
    """
    Purpose:
        Replace parts of a string

    Inputs:
        lsX      list with string, what is going to have its third position changed

    Return value:
        lsY      list with string, changes the fourth letter 
    """
    lsX[3] = ["h"]
    lsY = lsX

    return (lsY)

###########################################################
def fnReplacing_2(lX):
    """
    Purpose:
        Replace parts of a string

    Inputs:
        lX      list with many things

    Return value:
        lY      list with many things replacing the things on the original argument
    """
    lX[1] = [7]
    lX[2][1] = lX[2][1] ** 2
    lX[0][3] = 'h'
    lY = lX

    return (lY)

###########################################################    
### main
def main():
    # Magic numbers
    dX= 2

    # Initialisation
    dSX = fnSquare(dX)

#    With the suggestion from the slides the thing does not work
#    lsX = ['Aargus']
    lsX = list('Aargus')
    lsY = fnReplacing_1(lsX)   
    
    lX = [list('Aargus'), 5, [2.4, 4.6]]
    lY = fnReplacing_2(lX)

    # Output
    print ("1.1. dX squared is equal to dSX:", dSX, "\n")
    print ("1.2. Unlike the built-in ** operator, math.pow() converts both its arguments to type float. Use ** or the built-in pow() function for computing exact integer powers.")
    print ("2. Changing the value of dX inside the fnSquare function changes it only locally, not in global environment.")
    print ("3. pow.() and ** do not support lists.")
    print ("4. You cannot change parts of a string without replacing everything.")
    print ("5. Replacing gives us lsY =", lsY)
    print ("6. Replacing gives us lY =", lY)

###########################################################
### start main
if __name__ == "__main__":
    main()
