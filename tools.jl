using TrafficNetworks, SkeletonCities, JSON

function connect_net!(g::Graph, i::Int, j::Int)
    m = num_edges(g)
    edge = Edge(m+1, g.nodes[i], g.nodes[j])
    push!(g.edges, edge)
    push!(g.out_edges[g.nodes[i]], edge)
    push!(g.in_edges[g.nodes[j]], edge)
end

function sample_ensemble(root_n, α, β)
    points = α_set(root_n, α)
    g, lens, edge_tuples, node_images = periodic_net_w_lengths(points, β)
    g, lens, edge_tuples, node_images
end

function save_net_json(filename, g, edge_lengths, edge_tuples, node_images)
   jay =  json((g, edge_lengths, edge_tuples, node_images))
   write(filename, jay)
end

function save_net_json_nonperiodic(filename, g, edge_lengths)
   jay =  json((g, edge_lengths))
   write(filename, jay)
end

function load_net_json(filename)
    graph_dict, lens, tups, imgs = JSON.parsefile(filename)
    nodes = [Node(graph_dict["nodes"][i]["index"], graph_dict["nodes"][i]["pos"]) for i in 1:length(graph_dict["nodes"])]

    g = Graph()
    for n in nodes
        add_node!(g, n)
    end

    for i in 1:length(graph_dict["edges"])
        s = graph_dict["edges"][i]["source"]["index"]
        t = graph_dict["edges"][i]["target"]["index"]
        connect_net!(g, s, t)    
    end

    tups = Array{Tuple{Int,Int},1}([(tups[i][1], tups[i][2]) for i in 1:length(tups)])
    imgs = Array{Int,1}(imgs)

    g, lens, tups, imgs
end


"""
Crucial function for dealing with periodic boundaries...
Name of function should change as it actually does more than just calculate the 'true' lengths for the edges. But care must be taken that all functions that call this one are updated too when that change is done...
"""
function g_lens_for_sim(g_vis, lens_vis, edge_tuples_vis, node_images, root_n)
    n = Int(root_n^2)

    g_sim = Graph()
    for i in 1:n
        add_node!(g_sim, Node(i,g_vis.nodes[i].pos))
    end

    #map tuples
    mapped_tuples = Array{Tuple{Int,Int},1}()
    mapped_lengths = zeros(Float64, length(edge_tuples_vis))
    for (k,edge) in enumerate(edge_tuples_vis)
        i, j = edge
        s = node_images[i]
        t = node_images[j]
        push!(mapped_tuples, (s,t))
        mapped_lengths[k] = norm(g_vis.nodes[i].pos - g_vis.nodes[j].pos)
    end
    println(mapped_tuples)
    
    
    
    u_edges = map(x -> (node_images[x[1]],node_images[x[2]]) , edge_tuples_vis)
    unique_indices = indexin(unique(u_edges), u_edges)
    unique_edges = u_edges[unique_indices]
    unique_lengths = lens_vis[unique_indices]
    
    lens_sim = zeros(Float64, length(unique_edges))
    edge_copies_for_vis = Dict()
    for (i,e) in enumerate(mapped_tuples)
        if !(e in unique_edges)
            lens_sim[i] = lens_vis[i]
            edge_copies_for_vis[i] = find(x -> x==e, mapped_tuples)
            connect_net(g_sim, e...)
        end 
    end
    lens_sim = unique_lengths
    
    #unique_edges = Array{Tuple{Int,Int},1}()
    #lens_sim = Array{Float64,1}()
    #for (i,e) in enumerate(mapped_tuples)
    #    if !(t in unique_edges)
    #        push!(unique_edges, t)
    #        push!(lens_sim, lens_vis[i])
    #    end
    #end

    edge_copies_for_vis = Dict()
    for i in 1:length(unique_edges)
        t = unique_edges[i]
        edge_copies_for_vis[i] =  find(x -> x==t, mapped_tuples)
        connect_net!(g_sim, t[1], t[2])
    end
    g_sim, lens_sim, edge_copies_for_vis
end

"""
Loads road network from .json and .params file into a RoadNetwork object.
"""
function load_road_network(filename; periodic_conditions=false, param_file_exists=false)
    g_name = split(filename, '.')[1] 
    
    #this if statement here is bad function design...
    if param_file_exists
        params_file = g_name*".params"        
        params = readdlm(params_file)
        a, b = params[:,1], params[:,2]
    else
        warn("Cost parameter file not found. Loading RoadNetwork with empty cost parameter arrays...")
        a, b = [], []
    end
    
    if periodic_conditions
        g, a, edge_copies = g_lens_for_sim(g, lens, tups, imgs, sqrt(length(unique(imgs))))
    else
        g, a, tups, imgs = load_net_json(filename)
    end
    b = resource_allocation(g_sim, a)
    RoadNetwork(g, a, b)
end


#"""
#Associate edges according to their pre-image nodes.
#For dealing with periodic boundary conditions!
#"""
#function associate_edges(edge_array, node_images)
#    real_nodes = unique(node_images)
#    number_of_nodes = length(real_nodes)
#    
#    for i in 1:length(edge_array)
#        edge_array[i] = (node_images[edge_array[i][1]], node_images[edge_array[i][2]])
#    end
#    new_edge_array = unique(edge_array)
#end


function populate_flows_vis(edge_copies_for_vis, flows)
    indices = []
    for v in values(edge_copies_for_vis)
        append!(indices, v)
    end
    indices = sort(indices)
    max = indices[end]

    flows_vis = Array(Float64, max)
    for i in 1:length(edge_copies_for_vis)
        for j in edge_copies_for_vis[i]
            flows_vis[j] = flows[i]
        end
    end

    flows_vis
end


function resource_allocation(g, lens)
    M = num_edges(g)
    N = num_nodes(g)    
    degrees = Array{Int,1}([length(g.in_edges[n]) for n in g.nodes])
    sums_of_as = []
    for i in 1:N
        suma_of_a = sum([lens[j] for j in in_edges_idx(g.nodes[i],g)])
        push!(sums_of_as, suma_of_a)
    end

    lamb = 1.0 / ((1 ./ degrees) ⋅ sums_of_as)
    
    bs = Array(Float64, M)
    for n in g.nodes
        b = degrees[n.index] / lamb
        for j in in_edges_idx(n, g)
            bs[j] = b
        end
    end
   bs 
end


##########################################
##########################################
##########################################
#  Unused functions

function load_net(filename)
    graph_dict = JSON.parsefile(filename)
    nodes = [Node(graph_dict["nodes"][i]["index"], graph_dict["nodes"][i]["pos"]) for i in 1:graph_dict["num_nodes"]]
    lengths_of_edges = [graph_dict["edges"][i]["length"] for i in 1:graph_dict["num_edges"]]

    g = Graph()
    for n in nodes
        add_node!(g, n)
    end

    for i in 1:graph_dict["num_edges"]
        s = graph_dict["edges"][i]["source"]
        t = graph_dict["edges"][i]["target"]
        connect_net!(g, s, t)    
    end
    edge_images = graph_dict["edge_images"]

    g, lengths_of_edges, edge_images
end

