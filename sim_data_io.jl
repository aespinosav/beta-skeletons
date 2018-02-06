#FILE NOT IN USE, NEW FUNCTIONS HAVE BEEN DEFINED ELSEWHERE

using DataFrames


"""
Loads a data file (output from simulation) to a data frame for manipulation and analysis.

Basically this only makes sure that the tuples of the od pairs are read as tuples. Other changes might go in here though
This whole eval parsing thing is ugly...
"""
function load_beta_sim_data(filename)
    data = readtable(filename) 
    data[:od] = map(x -> eval(parse(x)), data[:od])
    data
end
