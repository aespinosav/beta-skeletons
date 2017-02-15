using TrafficNetworks, SkeletonCities, DataFrames, Convex, SCS
#This script should be run in the Data directory
# Function definitions

"""
Returns an array of N OD pairs for a given network N (uniformly chosen at random)
"""
function od_pairs(g, N)

    od_pair_array = Any[]

    for i in 1:N

        origin = rand(1:num_nodes(g))
        destination = rand(1:num_nodes(g))
        while destination == origin
            destination = rand(1:num_nodes(g))
        end

        push!(od_pair_array, [origin, destination])

    end

    od_pair_array
end

"""
Computes the cost of a specific flow pattern for linear cost function parameter vectors
a and b.

flows must be a row  of a data frame obtained with flows_data_frame (or same structure!)
that only contains the flows on the edges.
"""
function tot_cost(rn, flows)
    q_range = flows[:q]
    f = [flows[i][] for i in 1:length(flows)]
    cost = dot(rn.a, f) + dot(f, diagm(rn.b)*f)
end

########################################################################
########################################################################
########################################################################
# Script start
# running params

num_od_pairs = 10
num_of_graphs = 10
demand_range = collect(0.1:0.1:10) #Ends one order of magnitude larger than spatial size of city

##################

top_dir = pwd()
dirs_with_graphs = readdir()

data_frame = DataFrame(graph_id=Array{UTF8String,1}(),
                       od=Array{Array{Int64,1},1}(),
                       β=Array{UTF8String,1}(),
                       q=Array{Float64,1}(),
                       uecost=Array{Float64,1}(),
                       socost=Array{Float64,1}(),
                       poa=Array{Float64,1}())

for dir in dirs_with_graphs
    cd(dir)
    println("In $(dir)...")
    # Each dir corresponds to a value of beta
    β = parse(Float64 ,split(dir, '_')[end])
    beta_str = split(dir, '_')[end]

    files = readdir()

    split_files = map(x -> split(x, '.'), files)
    useful_files = files[find(x -> x[1][1] == 'g', split_files)]
    split_files = split_files[find(x -> x[1][1] == 'g', split_files)]

    graph_files = useful_files[find(x -> x[end] == "json", split_files)]
    param_files = useful_files[find(x -> x[end] == "txt", split_files)]

    if length(graph_files) < num_of_graphs  #How many networks to process per beta
        num_of_graphs = length(graph_files)
    end

    for i in 1:num_of_graphs

        graph_id = split(graph_files[i], '_')[1]
        id = "b"*beta_str*graph_id
        println("Run ID: $(id)")

        g = load_graph(graph_files[i])
        params = readdlm(param_files[i])

        a_vect = params[:,1]
        b_vect = params[:,2]

        od_list = od_pairs(g, num_od_pairs)

        for j in 1:num_od_pairs
            println("OD pair: $(od_list[j])")
            rn = RoadNetwork(g, a_vect, b_vect, od_list[j])

            sols_ue = ta_solve(rn, demand_range)
            sols_so = ta_solve(rn, demand_range, regime="SO")

            data_ue = flows_data_frame(sols_ue, rn, demand_range)
            data_so = flows_data_frame(sols_so, rn, demand_range)

            od = od_list[j]
            println("Appending to DataFrame...")
            for k in 1:length(demand_range)

                f_ue = data_ue[k, 2:end]
                f_so = data_so[k, 2:end]

                cost_ue = tot_cost(rn, f_ue)
                cost_so = tot_cost(rn, f_so)
                #rows have the following 'columns':     graphid | od_pair | beta | demand (q) | UE cost | SO cost | PoA
                row = @data [id, od, β, k, cost_ue, cost_so, cost_ue/cost_so]
                push!(data_frame, row)
            end
        end
    end
    println("Moving back to $(top_dir)\n\n")
    cd(top_dir)
end
