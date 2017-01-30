"""
Module that exports the functions to make beta_skeleton cities, for now the algorithm used
for generating the proximity graph is O(n^3), should be swapped out with the more efficient
one of O(n^2) when I have the time.
"""
module SkeletonCities

using TrafficNetworks

export beta_skeleton

include("dirtySkeleton.jl")

end
