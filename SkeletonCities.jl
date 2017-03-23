"""
Module that exports the functions to make beta_skeleton cities, for now the algorithm used
for generating the proximity graph is O(n^3), should be swapped out with the more efficient
one of O(n^2) when I have the time.
"""
module SkeletonCities

using TrafficNetworks

export beta_skeleton, save_graph, load_graph, save_graph_dot, load_tntp_to_dataframe,
       skeleton_road_network, load_beta_sim_data

include("dirtySkeleton.jl")
include("skele_road_net.jl")
include("graph_read_write.jl")
inlcude("sim_data_io.jl")
#include("tntp_interaction.jl") #Contains functions for loading .tntp files into data frames

end
