#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
bs3elim.py

Purpose:
    To add the computation for x in system Ax = b into the e0_elim.py

Version:
    1    First, imported things from other files
    2    Second, put it all together to use in incols.py

Date:
    2018/8/29

@author: Aishameriane Venes Schmidt
"""
###########################################################
### Imports
import numpy as np

###########################################################
### dS= fnCalcSum(mdA, vX, i)
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
### vX= fnBacksubs(mdA, vdB)
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
### vX= fnBacksubs(mdA, vdB)
def fnBacksubs1(mC):
    """
    Purpose:
      To solve the system Ax = b.

    Inputs:
      mC     the augmented matrix of the system Ax = b

    Outputs:
      none
      
    Return value:
      mdA    the A matrix from Ax = b
      vdB    the vector from Ax = b
      vX     solution to Ax = b
    """
    
    iN  = mC.shape[1]
    mdA = mC[:, :iN-1]
    vdB = mC[:, iN-1]
    vX  = fnBacksubs(mdA, vdB)

    return(vX)
###########################################################
### br= ElimElement(mC, i, j)
def ElimElement(mC, i, j):
    """
    Purpose:
      Eliminate one element [i,j] of a matrix, subtracting multiples
      of row j from row i

    Inputs:
      mC    iK x iK+iY matrix
      i     integer, number of row to eliminate
      j     integer, number of row with pivot

    Outputs:
      mC    iK x iK+iY matrix, with 0 created in location [i,j]

    Return value:
      br    boolean, True if all went well
    """
    if mC[j,j]== 0:
        return False

    # Find factor multiplying row j
    dF= mC[i,j] / mC[j,j]

    # Subtract dF times row j from row i
    mC[i,j:]= mC[i,j:] - dF*mC[j,j:]

    return True

###########################################################
### br= ElimColumn(mC)
def ElimColumn(mC, j):
    """
    Purpose:
      Eliminate one column [:,j] of a matrix, creating zeros below
      the pivot at [j,j]

    Inputs:
      mC    iK x iK+iY matrix
      j     integer, number of row with pivot

    Outputs:
      mC    iK x iK+iY matrix, with 0 created below [j,j]

    Return value:
      br    boolean, True if all went well
    """
    br= True
    iK= np.size(mC, 0)
    for i in range(j+1, iK):
        # print ("Starting row ", i)
        br= br and ElimElement(mC, i, j)
        # print ("resulting in mC= \n", mC)

    return br

###########################################################
### br= ElimGauss(mC)
def ElimGauss(mC):
    """
    Purpose:
      Eliminate a matrix, creating zeros at lower triangular

    Inputs:
      mC    iK x iK+iY matrix

    Outputs:
      mC    iK x iK+iY matrix, with 0 created below main diagonal

    Return value:
      br    boolean, True if all went well
    """
    iK= np.size(mC, 0)
    br= True
    for j in range(iK):
#        print ("Starting iteration ", j)
        br= br and ElimColumn(mC, j)
#        print ("resulting in mC= \n", np.around(mC,2))
    return br

###########################################################
### main
def main():
    # Magic numbers
    mX= [ [1,   1,   3],
          [1,  -1,  -3],
          [1,  -4,  -1],
          [1,   1,  -1],
          [1,   0,   2],
          [1,   1,  -2],
          [1,   2,   3],
          [1,   1,  -2],
          [1,  -5,   1],
          [1,  -3,  -4] ]
    vY= [ 6,  -1,  10,  -3,   4,
         -5,   1,  -5,  19,   2]

    # Transform inputs to matrices of floats
    mX= np.array(mX)
    iN= np.size(vY)
    vY= np.array(vY).reshape(iN, 1)

    # Prepare A= X'X, b= X'y, C= [A, b]
    mA= mX.T@mX
    vB= mX.T@vY
    mC= np.hstack((mA, vB))
    mC= mC.astype(float)

    print ("Initial matrix [A | b]: \n", mC);

    # Eliminate the mC matrix, resulting in [ mU | vC ]
    ir= ElimGauss(mC)
    print ("ElimGauss returns ir= ", ir,
           " with mC= \n", np.around(mC,2))
    vX = fnBacksubs1(mC)
    print("The solution for the system stated in mC is x=\n", np.around(vX,2))

###########################################################
### start main
if __name__ == "__main__":
    main()
