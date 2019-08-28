#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
vars.py

Purpose:
    Playing with differents types of variables

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
def assign_string(sX):
    """
    Purpose:
       Assign and printing a string

    Inputs:
        sX      sX is a string that you want to print

    Return value:
        sX      string, it is just the input
    """
#    sX = 'Hello, I am a string. Nice to meeting you!'
    
    print("My string is sX =", sX)

    return sX

###########################################################
def assign_dib(dX, iX, bX):
    """
    Purpose:
       Assign and printing a double/integer/boolean

    Inputs:
        dX      dX is a double that you want to print
        iX      iX is an integer that you want to print
        bX      bX is a boolean that you want to print
    Return value:
        dX      double, it is just the input
        iX      integer, it is just the input
        bX      boolean, it is just the input
    """
#    dX = 3.14
#    iX = 2
#    bX = True
          
    print("My double is dX =", dX)
    print("My integer is iX =", iX)
    print("My boolean is bX =", bX)

    return (dX, iX, bX)

###########################################################
def assign_list(lX, lY):
    """
    Purpose:
       Assign and printing a one/two-dimensional list

    Inputs:
        lX      lX is the one-dimensional list
        lY      lY is the two-dimensional list
        
    Return value:
        lX      list, it is just the input
        lY      list, it is just the input
 
    """
#    lX = [1, 2, 3, 4]
#    lY = [[1,2], [3,4]]
          
    print("My one-dimensional list is lX =", lX)
    print("My two-dimensional list is lY =", lY)


    return (lX, lY)

###########################################################  

def assign_numarray(lX):
    """
    Purpose:
       Assign and printing one of the lists to a numpy ndarray

    Inputs:
        lX      lX is the list
        
    Return value:
        vX      array, it is a numpy ndarray made of the input
 
    """
    vX = np.array(lX)  
             
    print("My list converted as array is vX =", vX)
    #print("My two-dimensional list converted as array is vY =", vY)
    
    # QUESTION
    # How do I see the size of the list correctly?
    # vX
    # vY
    # len(vX)
    # len(vY)
    # Check this out: https://stackoverflow.com/questions/15985389/python-check-if-list-is-multidimensional-or-one-dimensional

    return (vX)

########################################################### 
def assign_function(fnX):
    """
    Purpose:
       Assign and printing a function

    Inputs:
        fnX      fnX is the function to assign and print
        
    Return value:
        fnX      function, same as the input
 
    """
              
    print("My function is fnX =", fnX)
    
    return (fnX)

########################################################### 

### main
def main():
    # Magic numbers
    sX = 'Hello, I am a string. Nice to meeting you!'
    dX = 3.14
    iX = 2
    bX = True
    lX = [1, 2, 3, 4]
    lY = [[1,2,3], [3,4]]
    fnX = np.sum
    
    # Initialisation
    assign_string(sX)
    assign_dib(dX, iX, bX)
    assign_list(lX, lY)
    assign_numarray(lX)
    assign_numarray(lY)
    assign_function(fnX)
    
    # Output
    print ("This is definitely not an empty program\n")

###########################################################
### start main
if __name__ == "__main__":
    main()
