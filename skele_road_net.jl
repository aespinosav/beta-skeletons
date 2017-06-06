using TrafficNetworks

"""
Generates a β-skeleton with n nodes, for given beta. b_mult

skeleton_road_network(n, beta [, b_mult])

b_mult gives the scaling proportion such that b_mult*a is the maximum
allowed congestion paraemter 'b' per link.
"""
function skeleton_road_network(n, beta, b_mult=1.4)
    g = beta_skeleton(n, beta)

    a_params = Array{Float64,1}()
    b_params = Array{Float64,1}()

    for i in 1:num_edges(g)

        dist = norm(g.edges[i].target.pos - g.edges[i].source.pos)
        a = dist #this can be changed to introduce noise (should do...)
        b = rand()*b_mult*a # This can also be changed...

        push!(a_params, a)
        push!(b_params, b)
    end
    rn = RoadNetwork(g, a_params, b_params)
end

"""
Genereates a β-skeleton from an α-point set. The function is called like so,

skeleton_graph_αβ(n, α, β)

This function only returns the graph, NOT the road network.
"""
function skeleton_graph_αβ(n::Int, α::Float64, β::Float64)
    n_root = Int(sqrt(n)) #This will give an error if given a number of points 
    points = α_set(n_root, α)
    g = β_skeleton(points, β)
end


"""
Function that assigns cost parameters a and b (linear cost functions f(x) = a + bx)
to a graph that has coordinates for the nodes. This is based on euclidean distance.

The way b is assigned leaves much room for improvement.

usage,

    road_network_from_geom_graph(g::Graph, b_min_prop=0.1, b_max_prop=1.4)

"""
function road_network_from_geom_graph(g::Graph, b_min_prop=0.1, b_max_prop=1.4)
    a_params = Array{Float64,1}()
    b_params = Array{Float64,1}()

    for i in 1:num_edges(g)

        dist = norm(g.edges[i].target.pos - g.edges[i].source.pos)
        a = dist #this can be changed to introduce noise

        b_min = b_min_prop * a
        b_max = b_max_prop * a
        interval_length = b_max - b_min
        b = b_min + rand()*interval_length

        push!(a_params, a)
        push!(b_params, b)
    end
    rn = RoadNetwork(g, a_params, b_params)
end
