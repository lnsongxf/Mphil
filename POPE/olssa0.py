#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
olssa0.py

Purpose:
    To read data from US price index out of a csv file, calculate inflation, split data, make seasonal dummies, run a regression and plot results/diagnostics

Version:
    1       First start
    2       Finished up until graphs part
    

To-do:
    a. Clean code
    b. Separate in functions and lib files
    c. Organize output

Date:
    2019/08/29, 2019/08/30

Author:
    Aishameriane Venes Schmidt
"""
###########################################################
### Imports
import numpy as np
import pandas as pd
from datetime import datetime
import math as math
import matplotlib.pyplot as plt

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
    dfInflation = pd.read_csv("data\sa0_180827.csv")
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

    ## Dummy for months
    vMonths = [dfInflationSubset.at[i, 'Period'].month for i in range(len(vIntercept))]
    dfInflationSubset['MDummy'] = vMonths
    dfMonthDummies = pd.get_dummies(dfInflationSubset['MDummy'], drop_first=True)
    dfInflationSubset = pd.concat([dfInflationSubset, dfMonthDummies], axis=1)
    dfInflationSubset.drop(['MDummy'], inplace=True, axis=1)    
    
    ## Dummy for the different years     
    vDY1 = [(dfInflationSubset.at[i, 'Period'] >= dfDates[0]) for i in range(len(vIntercept))]  
    vDY2 = [(dfInflationSubset.at[i, 'Period'] >= dfDates[1]) for i in range(len(vIntercept))]
    vDY3 = [(dfInflationSubset.at[i, 'Period'] >= dfDates[2]) for i in range(len(vIntercept))]
    vDY4 = [(dfInflationSubset.at[i, 'Period'] >= dfDates[3]) for i in range(len(vIntercept))]
    vDY5 = [(dfInflationSubset.at[i, 'Period'] >= dfDates[4]) for i in range(len(vIntercept))]

    dfInflationSubset['Y1973'] = np.array(vDY1)*1
    dfInflationSubset['Y1976'] = np.array(vDY2)*1
    dfInflationSubset['Y1979'] = np.array(vDY3)*1
    dfInflationSubset['Y1982'] = np.array(vDY4)*1
    dfInflationSubset['Y1990'] = np.array(vDY5)*1
    
    ## Assembling the vY with independent variable and mdX with the regressors
    mdX = dfInflationSubset[["Intercept", 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, "Y1973", "Y1976", "Y1979", "Y1982","Y1990"]].copy()
    vdY = dfInflationSubset["Inflation"].copy()
    
    # Estimation
    print(np.around(np.linalg.lstsq(mdX, vdY, rcond = None)[0],4))
    print(np.average(vdY))
    vdBetahat = np.linalg.lstsq(mdX, vdY, rcond = None)[0]
    
    # Graphs
    ## Put y^ in a dataframe as well as the true values
    
    vYhat = pd.DataFrame(mdX @ vdBetahat)
    dfCompare = pd.concat([vdY, vYhat], axis=1)
    dfCompare = pd.concat([dfInflationSubset["Period"], dfCompare], axis=1)
    dfCompare.columns = ["Date", "True Inflation", "Estimated Inflation"]
    
    plt.figure(figsize=(10,7))   # Choose alternate size (def= (6.4,4.8))
    plt.subplot(2, 1, 1)            # Work with 2x1 grid, first plot
    
    plt.plot(dfCompare["Date"], dfInflationSubset["SA0"])                    # Simply plot the white noise
    plt.legend(["SA0"])     # Add a legend
    plt.title("Consumer price index SA0, US (1958-2018)")        # ... and a title

    plt.subplot(2, 1, 2)            # Start with second plot
    plt.plot(dfCompare["Date"], dfCompare[["True Inflation", "Estimated Inflation"]])
    plt.ylabel("Inflation")
    plt.legend(["True", "Estimated"]) 
    plt.xlabel("Time")
    plt.title("Real inflation and inflation estimated by a regression model")     # ... and name the graph
#    plt.savefig("graphs/plot1.png") # Save the result
    plt.show()                      # Done, show it
    
    
    # Output
    print ("This is an almost empty program\n")

###########################################################
### start main
if __name__ == "__main__":
    main()