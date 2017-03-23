using DataFrames

"""
Loads a data file (output from simulation) to a data frame for manipulation and analysis.

Basically this only makes sure that the tuples of the od pairs are read as tuples. Other changes might go in here though
"""
function load_beta_sim_data(filename)
    data = readtable(filename)
    
    map!(x -> eval(parse(x)), data[:od]))
    data[:od] = DataArray{Tuple{Int64,Int64},1}(data[:od]))

    data
end
