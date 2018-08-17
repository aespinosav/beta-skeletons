"""
Module that exports the functions to make beta_skeleton cities, for now the algorithm used
for generating the proximity graph is O(n^3), should be swapped out with the more efficient
one of O(n^2) when I have the time.
"""
module SkeletonCities

using TrafficNetworks

export 
    #From dirtySkeleton.jl
    β_skeleton,
    #From skele_road_net.jl
    skeleton_graph_αβ, skeleton_road_network,
    #From lattice.jl
    α_set,
    #From periodic_bc.jl
    periodic_net_w_lengths, torus_od, torus_od₂,
    #From plot_graph_tikz.jl
    save_graph_tikz, plot_flows_net,
    #From tools.jl
    sample_ensemble, save_net_json,
    load_net_json, g_lens_for_sim, populate_flows_vis,
    resource_allocation, load_road_network

include("dirtySkeleton.jl")
include("skele_road_net.jl")
#include("graph_read_write.jl")
#include("sim_data_io.jl")
include("lattice.jl")
include("periodic_bc.jl")
include("plot_graph_tikz.jl")
include("tools.jl") #Having this is messy, must fix!
end
