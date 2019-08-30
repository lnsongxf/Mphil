#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
fill3.py

Purpose:
    Fill matrix mX= [i * j]

Version:
    0       First start, within main
    1       Now within a function, returning mX
    2       And through a pre-declared argument
    3       Using a list comprehension, in main

Date:
    2019/08/29

@author: Aishameriane Venes Schmidt
"""
###########################################################
### Imports
import numpy as np

###########################################################
### main
def main():
    # Magic numbers
    iN= 5
    iK= 3

    # Initialisation
    
    # Use a list comprehension to fill mX, and reshape towards
    #   an n x k matrix
    mX = np.array([[np.random.rand() for i in range(iK)] for j in range(iN)])
    
    # Output
    print ("Output: mX=\n", mX)

###########################################################
### start main
if __name__ == "__main__":
    main()
