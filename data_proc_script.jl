using TrafficNetworks, SkeletonCities, DataFrames

#Input Data
data_dir = "~/Documents/phd/code/projects/beta-skeletons/Data"
data_file = "prelim_data.tsv"
data =  load_beta_sim_data(data_file)


#Get simulation run parameters
demand_range = length(unique(data[:q]))
graph_ids = unique(data[:graph_id])
number_of_graphs = length(graph_ids)
#This variable is done this way to catch if there are graphs for which STAP was run on a different number of od-pair instances
nuber_of_od_pairs_per_graph =   begin
                                    array = Int64[]
                                    for i in 1:number_of_graphs
                                        idx_list_1 = [find(x->x==graph_ids[i], data[:graph_id])] 
                                        for i in graph_ids
                                            num_of_ods = length(unique(data[idx_list_1][:od]))
                                            push!(array, num_of_ods)
                                        end
                                    end
                                end
#STAP has been solved for several, single od-pair, scenarios.
for id in graph_ids
    indices = find(x -> x==id, data[:graph_id])
    graph_data = data[indices, :]
    n = size(graph_data)[1]

    #od pairs that have been used
    od_pairs = unique(data[:od])
    #Average poa for od pairs over demand values
    Σpoa = 0 
    for q in demand_range
        graph_data[[:od, :q, :poa]] 
    end
end
