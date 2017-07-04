using TrafficNetworks, SkeletonCities

"""
Generates a beta skeleton with periodic boundary conditions
"""
function periodic_nets_w_edgelengths(point_set, β)
    
    N = length(point_set)

    translation_vects = [[-1 -1];
                         [-1 0];
                         [-1 1];
                         [0 1];
                         [1 1];
                         [1 0];
                         [1 -1];
                         [0 1]]
    
    mega_set = copy(point_set)
    for i in 1:8
        this_tiled_set = [point_set[j] + translation_vects[i,:]' for j in 1:N]
        for k in 1:N
            push!(mega_set, vec(this_tiled_set[k]))
        end
    end
    #mega_set

    g = β_skeleton(mega_set, β)
    
    edge_indices = []
    for i in 1:N
        incoming = g.in_edges[g.nodes[i]]
        in_indices = [j.index for j in incoming]
        outgoing = g.out_edges[g.nodes[i]]
        out_indices = [j.index for j in outgoing]

        push!(edge_indices, in_indices..., out_indices...)
    end
    edge_indices = sort(unique(edge_indices))

    sources = [g.edges[i].source.index for i in edge_indices]
    targets = [g.edges[i].target.index for i in edge_indices]

    edge_lengths = [norm(g.edges[i].target.pos - g.edges[i].source.pos) for i in edge_indices]

    mapped_sources = map(x -> mod(x, N)+1, sources)
    mapped_targets = map(x -> mod(x, N)+1, targets)

    edge_tuples = zip(mapped_sources, mapped_targets)
    g2 = Graph()
    for i in 1:N
        add_node!(g2, Node(i, point_set[i]))
    end
    for j in edge_tuples
        connect!(g2, j[1], j[2])
    end
    g2, edge_lengths
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
