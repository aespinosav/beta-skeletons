using TrafficNetworks

"""
    connect_net!(g::Graph, i::Int, j::Int)
    
Adds and edge pointing from node i to node j
"""
function connect_net_by_label!(g::Graph, a::Int, b::Int)
    m = num_edges(g)
    i = find(x -> x.index==a, g.nodes)
    j = find(x -> x.index==b, g.nodes)
    edge = Edge(m+1, g.nodes[i], g.nodes[j])
    push!(g.edges, edge)
    push!(g.out_edges[g.nodes[i]], edge)
    push!(g.in_edges[g.nodes[j]], edge)
end

"""
Checks if point 'p' is in the circle based region of points u and v
for given beta <= 1
"""
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

"""
Checks if point 'p' is in the lune based region of points u and v,
for beta > 1.
"""
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




function β_skeleton_periodic(points::Array{Float64,2}, β)
    
    if β <= 1
        in_C = in_C_1
    else
        in_C = in_C_2
    end
    
    n = size(points)[1]
    g = Graph()

    translation_vects = [-1 -1;
                         -1 0;
                         -1 1;
                          0 1;
                          1 1;
                          1 0;
                          1 -1;
                          0 -1]
    
    mega_set = copy(points)
    
    for i in 1:8
        this_tile = points .+ translation_vects[i,:]'
        mega_set = [mega_set; this_tile]
    end

    for i in 1:n
        add_node!(g, Node(i, points[i,:][:]))
    end

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
                connect_net!(g, j, i) #make two 1-way links
            end
        end
        
        for t in 1:8
            in_x_bound = find(x->x>-0.3&&x<1.3, mega_set[(t*n)+1:(t+1)*n,1])
            in_y_bound = find(y->y>-0.3&&y<1.3, mega_set[(t*n)+1:(t+1)*n,2])
            for j in intersect(in_x_bound,in_y_bound)
                
                t_next = mod(t+1,8) 
                t_prev = t>1?t-1:8
                
                k_range = union(1:n,   
                                t_prev*n+1:):(t_prev+1)*n, 
                                (t*n+1):(t+1)*n), 
                                t_next*n+1:):(t_next+1)*n)
                                )
                for k in k_range
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
                    v_node = Node(new_index, mega_set[j,:][:], true, mod(j, n))
                    add_node!(g, v_node)
                    connect_net!(g, i, new_index)
                    connect_net!(g, new_index, i)
                end 
            end
        end
    end
    g
end





    edge_indices = Int[]
    for i in 1:n
        incoming = g.in_edges[g.nodes[i]]
        in_indices = [j.index for j in incoming]
        outgoing = g.out_edges[g.nodes[i]]
        out_indices = [j.index for j in outgoing]
        push!(edge_indices, in_indices..., out_indices...)
    end
    edge_indices = sort(unique(edge_indices)) #we are counting the edges that connect the inner tile twice...

    #We get the nodes (in order), these are the real nodes, plus the image nodes that correspond to edges that cross the borders
    sources = Array{Int,1}([g.edges[i].source.index for i in edge_indices])
    targets = Array{Int,1}([g.edges[i].target.index for i in edge_indices])

    edge_lengths = Array{Float64,1}([norm(g.edges[i].target.pos - g.edges[i].source.pos) for i in edge_indices])
        
    available_node_indices = unique(sort(sources))
    extra_indices = available_node_indices[n+1:end]

    node_image(x) = Int(x - floor(x/(n+0.01))*n)
    node_images = Array{Int,1}([node_image(i) for i in available_node_indices])

    mapped_sources = Array{Int,1}([node_image(i) for i in sources])
    mapped_targets = Array{Int,1}([node_image(i) for i in targets])

    edge_tuples = Array{Tuple{Int,Int},1}()
    for i in 1:length(sources) #because all edges have a source
        s = find(x -> x==sources[i], available_node_indices)[1]
        t = find(x -> x==targets[i], available_node_indices)[1]
        push!(edge_tuples, (s,t))  
    end
     
    num_of_image_nodes = length(available_node_indices) - n

    #Construction of graph, nodes get relabeled to have consecutive indices
    #The information of which node they are an image of is kept in the array node_images
    g2 = Graph()
    for i in 1:(N + num_of_image_nodes)
        add_node!(g2, Node(i, mega_set[available_node_indices[i]][:]))
    end
    for j in edge_tuples
        connect_net!(g2, j[1], j[2])
    end
g2, edge_lengths, edge_tuples, node_images
end
