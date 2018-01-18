"""
Module that exports the functions to make beta_skeleton cities, for now the algorithm used
for generating the proximity graph is O(n^3), should be swapped out with the more efficient
one of O(n^2) when I have the time.
"""
module SkeletonCities

using TrafficNetworks

export beta_skeleton, β_skeleton, save_graph, load_graph,
       load_tntp_to_dataframe, skeleton_road_network,
       load_beta_sim_data, α_set, skeleton_graph_αβ,
       road_network_from_geom_graph, save_graph_tikz,
       periodic_net_w_lengths, torus_od,
       #From tools.jl
       connect_net!, sample_ensemble, save_net_json,
       load_net_json, g_lens_for_sim, populate_flows_vis,
       resource_allocation

include("dirtySkeleton.jl")
include("skele_road_net.jl")
include("graph_read_write.jl")
include("sim_data_io.jl")
include("lattice.jl")
include("periodic_bc.jl")
include("plot_graph_tikz.jl")
include("tools.jl") #The functions from this file must be integrated
#into the corresponding module...

#include("tntp_interaction.jl") #Contains functions for loading .tntp files into data frames
end
