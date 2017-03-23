#Script for plotting a single poa trace for one of the networks over the simulated demand range
using TrafficNetworks, SkeletonCities, DataFrames, Gadfly

#load data from location on machine (big data files can take a while... care must be taken with how much memory this will take) 
data_dir = "/space/ae13414/Data/beta-skeletons"
data_filename = "prelim_data.tsv"
data = load_beta_sim_data(data_filename)

#Choose the id for the graph and run we want to plot poa vs demand for...
id_string = "b1.00g001" #change this manually for specific network
od_pair_index = 1 #choose which od pair to do it for
id = utf8(id_string) #make sure it is a utf8 string

#Get β value
β = float(split(id_string, 'g')[1][2:end])

idxs_1 = find(x -> x==id, data[:graph_id])
data_frame_to_plot = data[idxs_1, :]

#Get od value
od = unique(data_frame_to_plot[:od])[od_pair_index]

idxs_2 = find(x -> x==od, data_frame_to_plot[:od])
data_frame_to_plot = data_frame_to_plot[idxs_2,:]

#labels 
xlabel = "Demand (q)"
ylabel = "PoA"
title = "N=100, β=$β, od=$od"

#Name of file to save pdf plot as
target_file_name = id*"od_$(od[1])-$(od[2])_"*".pdf"

p = plot(data_frame_to_plot,
         x=:q, 
         y=:poa,
         Geom.line,
         Guide.Title(title),
         Guide.Xlabel(xlabel),
         Guide.Ylabel(ylabel))

draw(PDF(target_file_name, 4inch, 3inch), p)
