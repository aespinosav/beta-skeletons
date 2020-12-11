#Script with faster way of generating larger beta skeletons (up to 40x40 works well) Still way to much memory allocation going on though.
#

import Base.show, Base.length, TrafficNetworks.add_node!, TrafficNetworks.connect_net!, TrafficNetworks.num_nodes, TrafficNetworks.num_edges, TrafficNetworks.adjacency_matrix, TrafficNetworks.adjacency_matrix_non_sparse, TrafficNetworks.incidence_matrix, 	TrafficNetworks.incidence_matrix_non_sparse
type Node
    index::Int
    pos::Array{Float64,1}
    virtual::Bool
    img_indx::Int #0 if not virtual node
end
show(io::IO, n) = print(io, "<$(n.index)> $(n.pos) im:$(n.img_indx)")
Node() = Node(0, Float64[], false, 0)


type Edge
    index::Int
    source
    target
end
show(io::IO, e::Edge) = print(
                         io, 
                         "<$(e.index)> ($(e.source.index) → $(e.target.index))"
                         )

length(e::Edge) = norm(e.target.pos - e.source.pos)

# New graph types (should be mutables I guess...) for 
"""
Graph with periodic BCs nodes are defined differently
"""
type PGraph
    nodes::Array{Node,1}
    edges::Array{Edge,1}
    in_edges::Dict{Node, Array{Edge,1}}
    out_edges::Dict{Node, Array{Edge,1}}
end
PGraph() = PGraph(
               Array{Node,1}[], 
               Array{Edge,1}[], 
               Dict{Node, Array{Edge,1}}(), 
               Dict{Node, Array{Edge,1}}()
               )


function add_node!(g::PGraph, n::Node)
    indx = num_nodes(g) + 1
    n.index = indx

    push!(g.nodes, n)
    g.in_edges[n] = Edge[]
    g.out_edges[n] = Edge[] 
end
add_node!(g) = add_node!(g, Node(-1, Float64[])) 

function connect_net!(g, n_i, n_j)
    m = num_edges(g)
    edge = Edge(m+1, n_i, n_j)
    push!(g.edges, edge)
    push!(g.out_edges[n_i], edge)
    push!(g.in_edges[n_j], edge)
end
connect_net!(g, i::Int, j::Int) = connect_net!(g, g.nodes[i], g.nodes[j])

function num_nodes(g)
    length(g.nodes)
end

function num_edges(g)
    length(g.edges)
end

function adjacency_matrix(g)
    n = num_nodes(g)
    A = spzeros(n,n)
    for e in g.edges
        i, j = e.source.index, e.target.index
        A[i,j] += 1
    end
    A
end

function adjacency_matrix_non_sparse(g)
    A = adjacency_matrix(g)
    full(A)
end

function incidence_matrix(g)
    n = num_nodes(g)
    m = num_edges(g)
    M = spzeros(Int64, n, m)

    #Go through all nodes
    for i in 1:n
        out_e = out_edges_idx(i, g)
        in_e = in_edges_idx(i,g)
        #Outgoing edges
        for j in out_e
            M[i,j] = -1
        end
        #Incoming edges
        for j in in_e
            M[i,j] = 1
        end
    end
    M
end

function incidence_matrix_non_sparse(g)
    full(incidence_matrix(g))
end


### beta skeleton            
function in_C_1(p, u, v, beta)
    vect = v - u
    mag = norm(vect)
    perp = [-vect[2], vect[1]]

    d = mag/beta
    r = 0.5*d

    c1 = u + 0.5*vect + sqrt(r^2 - (mag^2)/4)*(perp/mag)
    c2 = u + 0.5*vect - sqrt(r^2 - (mag^2)/4)*(perp/mag)

    incircle_1 = norm(p - c1) < r
    incircle_2 = norm(p - c2) < r

    incircle_1 && incircle_2
end
function in_C_2(p, u, v, beta)
    vect = v - u
    mag = norm(vect)

    unit_vect = vect/mag    #Unit vector that points from u -> v.

    perp = [-vect[2], vect[1]]

    r = beta*mag*0.5

    c1 = v - r*unit_vect    #Centre of circle that has u in its interior
    c2 = u + r*unit_vect    #Centre of circle that has v in its interior

    onright = sign(dot(perp, p - u)) > 0
    incircles = norm(p - c1) < r && norm(p - c2) < r
end            
"""
A faster algorithm that approximates the periodic bc for the beta skeleton.
"""
function β_skeleton_periodic(points::Array{Float64,2}, β)   
    if β <= 1
        in_C = in_C_1
    else
        in_C = in_C_2
    end
    
    n = size(points)[1]
    g = PGraph()
    translation_vects = [-1 -1;
                         -1 0;
                         -1 1;
                          0 1;
                          1 1;
                          1 0;
                          1 -1;
                          0 -1]
    mega_set = points
    
    for i in 1:8
        this_tile = points .+ translation_vects[i,:]'
        mega_set = [mega_set; this_tile]
    end

    for i in 1:n
        add_node!(g, Node(i, points[i,:][:], false, 0))
    end

    #Connect main nodes
    for i in 1:n
        for j in (i+1):n
            isempty = true
            for k in 1:(9*n)
                if i != k && j !=k
                    p = mega_set[k,:][:]
                    u = g.nodes[i].pos
                    v = mega_set[j,:][:]

                    if in_C(p,u,v,β)
                        isempty = false
                        break
                    end
                end
            end
            if isempty               
                connect_net!(g, i, j)
                connect_net!(g, j, i)
            end
        end
        
        #Connect across boundaries (for the points in the tiles closes to the boundaries ~ 1/3 of the length scale of the tiles)
        for t in 1:8
            in_x_bound = find(x->x>-0.3&&x<1.3, mega_set[(t*n)+1:(t+1)*n,1])
            in_y_bound = find(y->y>-0.3&&y<1.3, mega_set[(t*n)+1:(t+1)*n,2])
            for j in intersect(in_x_bound, in_y_bound) .+ t*n
                isempty = true
                
                for k in 1:n*9
                    if i != k && j !=k
                        p = mega_set[k,:][:]
                        u = g.nodes[i].pos
                        v = mega_set[j,:][:]

                        if in_C(p,u,v,β)
                            isempty = false
                            break
                        end
                    end
                end
                if isempty
                    new_index = num_nodes(g)+1
                    v_node = Node(new_index, mega_set[j,:][:], true, mod(j, n)==0?n:mod(j,n))
                    add_node!(g, v_node)
                    connect_net!(g, i, new_index)
                    connect_net!(g, new_index, i)
                end 
            end
        end
    end
    
    #edge_tuples = [(e.source.index, e.target.index) for e in g.edges]
    edge_lengths = [length(e) for e in g.edges]
    node_images = map(n->n.virtual?n.img_indx:n.index, g.nodes) 
    
    
    edge_indices = []
    for i in 1:n
        incoming = g.in_edges[g.nodes[i]]
        in_indices = [j.index for j in incoming]
        outgoing = g.out_edges[g.nodes[i]]
        out_indices = [j.index for j in outgoing]
        push!(edge_indices, in_indices..., out_indices...)
    end
    edge_indices = sort(unique(edge_indices))
    
    sources = Array{Int,1}([g.edges[i].source.index for i in edge_indices])
    targets = Array{Int,1}([g.edges[i].target.index for i in edge_indices])

    
    available_node_indices = unique(sort(sources))
    extra_indices = available_node_indices[n+1:end]
    
    mapped_sources = Array{Int,1}([node_images[i] for i in sources])
    mapped_targets = Array{Int,1}([node_images[i] for i in targets])

    edge_tuples = Array{Tuple{Int,Int},1}()
    for i in 1:length(sources) #because all edges have a source
        s = find(x -> x==sources[i], available_node_indices)[1]
        t = find(x -> x==targets[i], available_node_indices)[1]
        push!(edge_tuples, (s,t))  
    end
    
    g, edge_lengths, edge_tuples, node_images
end

β_skeleton_periodic(n, α, β) = begin
                                   points = α_set(n, α)
                                   β_skeleton_periodic(points, β)
                               end 
