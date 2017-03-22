IDEA FOR GENERIC ROAD NETWORK OBJECT
====================================

Have the RoadNetwork contain the graph for its topology
and instead of vectors a and b for the parameters, it should have
dictionary or something like it of the parameters for its edge cost functions
and an actual function (vector or generic... ?) from which the costs
functions are retrieved. This would mean this object would have to interface
with Convex.jl a lot more in order to get that to work smoothly, since we
cananot guarantee that the user will use convex functions or not.
