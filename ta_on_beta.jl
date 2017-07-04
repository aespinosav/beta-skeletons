#This script should be run in the Data directory
#Runs traffic assignment on graphs from files (specifically β-skeleton nets)
#I think this script only works if all the dirs have the same number of networks...

using TrafficNetworks, SkeletonCities, DataFrames, Convex, SCS

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

        push!(od_pair_array, (origin, destination))
    end
   od_pair_array
end

"""
Computes the cost of a specific flow pattern for linear cost function parameter vectors
a and b.

flows must be a row of a data frame obtained with flows_data_frame (or same structure!)
that only contains the flows on the edges.
"""
function tot_cost(rn, flows)   
   #q_range = flows[:q]
    flows = flows[2:end]
    f = [flows[i][] for i in 1:length(flows)]
    cost = dot(rn.a, f) + dot(f, diagm(rn.b)*f)
end

# Script start
# running params
# once running should be change to script params at runtime...


#Model parameters
num_od_pairs = 10
num_of_graphs = 10
demand_range = collect(0.1:0.1:10)

#Script parameters (Where the data is read from and written to...))
top_dir = "/space/ae13414/Data/beta-skeleton"
cd(top_dir)
dirs_with_graphs = readdir()

#Data frame that contains output data (note that we should have the files..)
#This is pretty much a db schema!! NOTE: only for SINGLE OD PAIRS
data_frame = DataFrame(graph_id=Array{UTF8String,1}(),
                       od=Array{Tuple{Int64,Int64},1}(),
                       β=Array{Float64,1}(),
                       q=Array{Float64,1}(),
                       uecost=Array{Float64,1}(),
                       socost=Array{Float64,1}(),
                       poa=Array{Float64,1}())

#Script run start
for dir in dirs_with_graphs
    # Each dir corresponds to a value of beta
    # Should follow our naming convetion eg. dirs: 'beta_1.14' files: 'g031_beta_1.23.json'
    cd(dir)
    println("\n\nIn dir:$(dir )...")

    #Prepping of files/file structure
    files = readdir()
    split_files = map(x -> split(x, '.'), files)
    useful_files = files[find(x -> x[1][1] == 'g', split_files)]
    split_files = split_files[find(x -> x[1][1] == 'g', split_files)]

    graph_files = useful_files[find(x -> x[end] == "json", split_files)]
    param_files = useful_files[find(x -> x[end] == "txt", split_files)]
    
    #Get beta-skeleton parameter: β
    β = parse(Float64 ,split(dir, '_')[end])
    beta_str = split(dir, '_')[end]

    if length(graph_files) < num_of_graphs  #How many networks to process per beta
        num_of_graphs = length(graph_files)
        println("Not enough network files...  Will only solve for $(num_of_graphs) available\n")
    end

    for i in 1:num_of_graphs

        graph_id = split(graph_files[i], '_')[1]
        id = "b"*beta_str*graph_id
        println("Run ID: $(id)")
        
        #Read in graph and param files
        g = load_graph(graph_files[i])
        params = readdlm(param_files[i])

        a_vect = params[:,1]
        b_vect = params[:,2]
        
        #Generate od pairs
        od_list = od_pairs(g, num_od_pairs)

        for j in 1:num_od_pairs
            od = od_list[j]
            println("\tOD pair: $(od)")

            #Make road network
            rn = RoadNetwork(g, a_vect, b_vect)
            #Make OD matrix
            OD = od_matrix_from_pair(rn.g, od)
            #Solve optimisation routine
            sols_ue = ta_solve(rn, OD, demand_range)
            sols_so = ta_solve(rn, OD, demand_range, regime="SO")

            #Generate data frames for UE and SO equilibria
            data_ue = flows_data_frame(sols_ue, demand_range)
            data_so = flows_data_frame(sols_so, demand_range)

            #println("Appending to DataFrame...")
            for k in 1:length(demand_range)

#               f_ue = data_ue[k, 2:end]
#               f_so = data_so[k, 2:end]

                cost_ue = tot_cost(rn, data_ue[k,:])
                cost_so = tot_cost(rn, data_so[k,:])

                poa = cost_ue/cost_so

               #rows have the following 'columns': graphid | od_pair | beta | demand (q) | UE cost | SO cost | PoA
                row = data([id; od; β; k; cost_ue; cost_so; cost_ue/cost_so])
                push!(data_frame, row)
            end
        end
        println("Finished for $id \n")
    end
    println("Moving back to $(top_dir)\n\n")
    cd(top_dir)
end
