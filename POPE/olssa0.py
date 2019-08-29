#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
olssa0.py

Purpose:
    To read data from US price index out of a csv file, calculate inflation, split data, make seasonal dummies, run a regression and plot results/diagnostics

Version:
    1       First start

Date:
    2019/08/29

Author:
    Aishameriane Venes Schmidt
"""
###########################################################
### Imports
import numpy as np
import pandas as pd
from datetime import datetime
import math as math

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
    dfInflation = pd.read_csv("C:\\Users\\aisha\\OneDrive\\Documentos\\Mestrado Tinbergen\\Year 1\\Block 0\\Principles of Programming 2019-0\\Assignment\\OLS SA\\data\\sa0_180827.csv")
    iR = dfInflation.shape[0]
    iC = dfInflation.shape[1]
    sStartDate = '1958/01'
    iMonths = 11
    dDate1  = "1973/7"
    dDate2  = "1976/7"
    dDate3  = "1979/1"
    dDate4  = "1982/7"
    dDate5  = "1990/1"
    dfDates = pd.DataFrame([dDate1, dDate2, dDate3, dDate4, dDate5])
    dfDates = pd.to_datetime(dfDates[0], format='%Y/%m')
    # Initialisation
    
    ## Getting to know the dataframe
    dfInflation.shape # rows and columns
    dfInflation.head(5)
    
    ### Getting one column 
    dfInflation['Period']
    dfInflation['SA0']    
    type(dfInflation.at[1, 'Period'])
    type(dfInflation.at[1, 'SA0'])

#   Works
#   dfInflation['Period'] = [datetime.strptime(dfInflation.at[i, 'Period'], '%Y/%m') for i in range(iR)]
#   Also works and is done in pandas
    dfInflation['Period'] = pd.to_datetime(dfInflation['Period'], format='%Y/%m')

    ### Adding an index to the timestamp
    dfInflation.set_index('Period', inplace=False)
     
    ## Calculating the inflation rate and adding in the dataframe
    vInflation = np.zeros_like(dfInflation['SA0'])
    for i in range(1, iR):
        vInflation[i] = 100*(math.log(dfInflation.at[i,'SA0'])-math.log(dfInflation.at[i-1,'SA0']))     
    dfInflation['Inflation'] = vInflation
     
    ## Subsetting the csv file
    iDateMask  = (dfInflation['Period'] > sStartDate)
    dfInflationSubset = dfInflation.loc[iDateMask, :].copy() # starts on line 457 ends on 1182
    dfInflationSubset = dfInflationSubset.reset_index()
    
    ## Preparing the regressors
    vIntercept = np.ones_like(dfInflationSubset["SA0"])
    dfInflationSubset["Intercept"] = vIntercept

    vMonths = [dfInflationSubset.at[i, 'Period'].month for i in range(len(vIntercept))]
    dfInflationSubset['MDummy'] = vMonths
    dfMonthDummies = pd.get_dummies(dfInflationSubset['MDummy'], drop_first=True)
    dfInflationSubset = pd.concat([dfInflationSubset, dfMonthDummies], axis=1)
    dfInflationSubset.drop(['MDummy'], inplace=True, axis=1)    
         
    vDY1 = [(dfInflationSubset.at[i, 'Period'] == dfDates[0]) for i in range(len(vIntercept))]
    vDY2 = [(dfInflationSubset.at[i, 'Period'] == dfDates[1]) for i in range(len(vIntercept))]
    vDY3 = [(dfInflationSubset.at[i, 'Period'] == dfDates[2]) for i in range(len(vIntercept))]
    vDY4 = [(dfInflationSubset.at[i, 'Period'] == dfDates[3]) for i in range(len(vIntercept))]
    vDY5 = [(dfInflationSubset.at[i, 'Period'] == dfDates[4]) for i in range(len(vIntercept))]
    vDY1 = np.array(vDY1*1)
    vDY2 = np.array(vDY2*1)
    vDY3 = np.array(vDY3*1)
    vDY4 = np.array(vDY4*1)
    vDY5 = np.array(vDY5*1)
    
    dfInflationSubset['Y1973'] = vDY1*1
    dfInflationSubset['Y1976'] = vDY2*1
    dfInflationSubset['Y1979'] = vDY3*1
    dfInflationSubset['Y1982'] = vDY4*1
    dfInflationSubset['Y1990'] = vDY5*1
    
#    dfInflationSubset.columns
    mdX = dfInflationSubset[["Intercept", 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, "Y1973", "Y1976", "Y1979", "Y1982","Y1990"]].copy()
    vdY = dfInflationSubset["Inflation"].copy()
    
    # Estimation
    print(np.linalg.lstsq(mdX, vdY, rcond = None)[0])
    print(np.average(vdY))
    # Output
    print ("This is an almost empty program\n")

###########################################################
### start main
if __name__ == "__main__":
    main()