using TrafficNetworks, SkeletonCities, DataFrames

#Input Data
data_dir = "~/Documents/phd/code/projects/beta-skeletons/Data"
data_file = "prelim_data.tsv"
data =  load_beta_sim_data(data_file)

#Get id strings to tag the networks
graph_ids = unique(data[:graph_id])

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
