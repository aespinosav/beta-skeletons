using TrafficNetworks, SkeletonCities

"""
Generates a beta skeleton with periodic boundary conditions. This is not the most efficient as
it should only be skeletonising with pairs of nodes that require one of them to be from the centere tile.
"""
function periodic_net_w_lengths(point_set, β)
    
    N = length(point_set)

    translation_vects = [-1 -1;
                         -1 0;
                         -1 1;
                          0 1;
                          1 1;
                          1 0;
                          1 -1;
                          0 -1]
    
    mega_set = copy(point_set)
    
    for i in 1:8
        this_tile = broadcast(+, point_set, translation_vects[i,:])
        mega_set = vcat(mega_set, this_tile)
    end
     
    g = β_skeleton(mega_set, β) #This is not the best way of doing this...
    
    #Makes an array of the indices of the edges that matter
    edge_indices = []
    for i in 1:N
        incoming = g.in_edges[g.nodes[i]]
        in_indices = [j.index for j in incoming]
        outgoing = g.out_edges[g.nodes[i]]
        out_indices = [j.index for j in outgoing]
        push!(edge_indices, in_indices..., out_indices...)
    end
    edge_indices = sort(unique(edge_indices)) #we are counting the edges that connect the inner tile twice...

    #We get the nodes (in order), these are the real nodes, plus the ones that correspond
    #to edges that cross the borders
    sources = Array{Int,1}([g.edges[i].source.index for i in edge_indices])
    targets = Array{Int,1}([g.edges[i].target.index for i in edge_indices])

    edge_lengths = Array{Float64,1}([norm(g.edges[i].target.pos - g.edges[i].source.pos) for i in edge_indices])
        
    available_node_indices = unique(sort(sources))
    extra_indices = available_node_indices[N+1:end]

    node_image(x) = Int(x - floor(x/(N+0.01))*N)
    node_images = Array{Int,1}([node_image(i) for i in available_node_indices])

    mapped_sources = Array{Int,1}([node_image(i) for i in sources])
    mapped_targets = Array{Int,1}([node_image(i) for i in targets])

    edge_tuples = Array{Tuple{Int,Int},1}()
    for i in 1:length(sources) #because all edges have a source
        s = find(x -> x==sources[i], available_node_indices)[1]
        t = find(x -> x==targets[i], available_node_indices)[1]
        push!(edge_tuples, (s,t))  
    end
     
    num_of_image_nodes = length(available_node_indices) - N

    #Construction of graph, nodes get relabeled to have consecutive indices
    #The information of which node they are an image of is kept in the array node_images
    g2 = Graph()
    for i in 1:(N + num_of_image_nodes)
        add_node!(g2, Node(i, mega_set[available_node_indices[i],:][:]))
    end
    for j in edge_tuples
        connect!(g2, j[1], j[2])
    end

    g2, edge_lengths, edge_tuples, node_images
end


"""
Returns an od matrix (sparse) that is maximal distant points
"""
function torus_od(rn::RoadNetwork)
    g = rn.g
    N = num_nodes(g)
    norms = [norm(g.nodes[i].pos) for i in 1:N]
    o = indmin(norms)
    dists_from_center = [norm(g.nodes[i].pos - [0.5,0.5]) for i in 1:N]
    d = indmin(dists_from_center)
    od_matrix_from_pair(g, (o,d))
end
