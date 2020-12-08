% The program for the article "Solving the incomplete markets model with
% aggregate uncertainty using the Krusell-Smith algorithm" from the special 
% JEDC issue edited by Den Haan, Judd and Juillard (2008)  
%
% Written by Lilia Maliar, Serguei Maliar and Fernando Valli (2008)
% 
% The program includes the following files: 
%
% 1. "MAIN.m" (computes a solution and stores the results in "Solution")
% 2. "SHOCKS.m"      (a subroutine of MAIN.m; generates the shocks)
% 3. "INDIVIDUAL.m"  (a subroutine of MAIN.m; computes a solution to the 
%                     individual problem)
% 4. "AGGREGATE_ST.m"   (a subroutine of MAIN.m; performs the stochastic 
%                        simulation)
% 5. "AGGREGATE_NS.m"   (a subroutine of MAIN.m; performs the non-stochastic 
%                        simulation)
% 6. "Inputs_for_test" (contains initial distribution of capital and 
%    10,000-period realizations of aggregate shock and idiosyncratic shock 
%    for one agent provided by Den Haan, Judd and Juillard, 2008) 
% 7. "TEST.m" (should be run after "MAIN.m"; it uses "Inputs_for_test" and
%    "Solution_to_model" for computing the statistics reported in Den Haan's
%    2008, comparison article)  
%
% See the web page of the authors for the updated versions of the program 
% __________________________________________________________________________
