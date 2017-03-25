#Script for plotting a single poa trace for one of the networks over the simulated demand range
using TrafficNetworks, SkeletonCities, DataFrames, Gadfly

#load data from location on machine (big data files can take a while... care must be taken with how much memory this will take) 
current_dir = pwd()
data_dir = "/space/ae13414/Data/beta-skeleton"
data_filename = "prelim_data.tsv"

#Where to save the resulting graph
save_dir = "/space/ae13414/phd/projects/beta-skeletons/writeup"

cd(data_dir)
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
target_file_name = id*"od_$(od[1])-$(od[2])"*".pdf"

#Custom theme for adjusting fontsize and things
custom_theme = Theme(
    plot_padding=0.1inch,
    major_label_font_size=9pt,
    minor_label_font_size=6pt
    )

#Configure xticks and yticks
min_q = 0.0
max_q = maximum(data_frame_to_plot[:q])
q_step = data_frame_to_plot[:q][2] - data_frame_to_plot[:q][1]

min_poa = 1.0
max_poa_data = maximum(data_frame_to_plot[:poa])
max_poa_theoretical = 4.0/3.0 #For affine cost functions

q_ticks = collect(min_q:20*q_step:max_q) #we are going off the fact that we are plotting 100 q values... 

if abs(max_poa_theoretical - max_poa_data) < 0.1
    intercept = [max_poa_theoretical]  
    poa_ticks = collect(1.0:0.1:1.4)
else
    intercept = []
    poa_ticks = collect(1.0:0.01:max_poa_data+0.01)
end

p = plot(data_frame_to_plot,
         x=:q, 
         y=:poa,
         yintercept=intercept,
         Geom.line,
         Geom.hline(color=colorant"black"),
         Guide.Title(title),
         Guide.XLabel(xlabel),
         Guide.YLabel(ylabel),
         Guide.xticks(ticks=q_ticks),
         Guide.yticks(ticks=poa_ticks),
         custom_theme)

cd(save_dir)
draw(PDF(target_file_name, 4inch, 3inch), p) #save pdf graph
cd(current_dir)
