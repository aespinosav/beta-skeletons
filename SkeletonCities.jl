"""
Module that exports the functions to make beta_skeleton cities, for now the algorithm used
for generating the proximity graph is O(n^3), should be swapped out with the more efficient
one of O(n^2) when I have the time.
"""
module SkeletonCities

using TrafficNetworks

export beta_skeleton, save_graph, load_graph

include("dirtySkeleton.jl")
include("graph_read_write_json.jl")

end
