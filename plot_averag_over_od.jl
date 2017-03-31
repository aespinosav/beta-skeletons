#Script for plotting an average PoA trace for a single β-skeleton network averaged over a set of OD pairs
using SkeletonCities, DataFrames, Gadfly

#load data from location on machine (big data files can take a while...  care must be taken with how much memory this will take)
current_dir = pwd()
data_dir = "/space/ae13414/Data/beta-skeleton"
data_filename = "prelim_data.tsv"

#Where to save the resulting graph
save_dir = "/space/ae13414/phd/projects/beta-skeletons/writeup"

cd(data_dir)
data = load_beta_sim_data(data_filename)

#Choose the id for the graph and run we want to plot poa vs demand for...
id_string = "b1.00g001" #change this manually for specific network
id = utf8(id_string) #make sure it is a utf8 string
g_id = split(id_string, 'g')[2]

#Get β value
β = float(split(id_string, 'g')[1][2:end])

#Get od pairs
idxs_1 = find(x -> x==id, data[:graph_id]) #indices in array for graph with selected id.
#ods = unique(data[find(idxs_1,:][:od]))

#Get demand range assumes equal step sizes
min_q = 0.0
max_q = maximum(data[:q])
q_step = data[idxs_1,:][:q][2] - data[idxs_1,:][:q][1]

q_range = collect(min_q:q_step:max_q)

#Make new data frame for easy plotting
#new_data = DataFrame(q=Array{Float64,1}(),
#                     uecost=Array{Float64,1}(),
#                     ue_std=Array{Float64,1}(),
#                     socost=Array{Float64,1}(),
#                     so_std=Array{Float64,1}(),
#                     poa=Array{Float64,1}(),
#                     poa_std=Array{Float64,1}())


new_data = DataFrame(q=Array{Float64,1}(),
#                     uecost=Array{Float64,1}(),
#                     ue_std=Array{Float64,1}(),
#                     socost=Array{Float64,1}(),
#                     so_std=Array{Float64,1}(),
                     poa=Array{Float64,1}(),
                     poa_std=Array{Float64,1}())

for q in q_range

    idxs_2 = find(x -> x==q, data[:q])
    df = data[intersect(idxs_1, idxs_2),:]

    #ue_cost, ue_std = mean_and_std(df[:uecost])
    #so_cost, so_std = mean_and_std(df[:socost])
    poa, poa_std = mean_and_std(df[:poa])

#    row = data([β, q, ue_cost, ue_std, so_cost, so_std, poa, poa_std])

    row = DataArray{Float64,1}([q, poa, poa_std])
    push!(new_data, row)
end

#labels
xlabel = "Demand (q)"
ylabel = "PoA"
title = "β=$β, Graph: $g_id"


#Name of file to save pdf plot as
target_file_name = id*"average_over_ods.pdf"

#Custom theme for adjusting fontsize and things
custom_theme = Theme(plot_padding=0.1inch,
                     major_label_font_size=9pt,
                     minor_label_font_size=6pt
                    )

#Configure xticks and yticks
min_poa = 1.0
max_poa_data = maximum(new_data[:poa])
max_poa_theoretical = 4.0/3.0 #For affine cost functions

q_ticks = collect(min_q:20*q_step:max_q)

if abs(max_poa_theoretical - max_poa_data) < 0.1
    intercept = [max_poa_theoretical]
    poa_ticks = collect(1.0:0.1:1.4)
else
    intercept = []
    poa_ticks = collect(1.0:0.01:max_poa_data+0.01)
end

#plot the damn graph

pos_err = new_data[:poa] .+ new_data[:poa_std] 
neg_err = new_data[:poa] .- new_data[:poa_std]
p = plot(new_data,
         x=:q,
         y=:poa,
         ymin=pos_err,
         ymax=neg_err,
         yintercept=intercept,
         Geom.line,
         Geom.ribbon,
         Geom.hline(color=colorant"black"),
         Guide.Title(title),
         Guide.XLabel(xlabel),
         Guide.YLabel(ylabel),
         Guide.xticks(ticks=q_ticks),
         Guide.yticks(ticks=poa_ticks),
         custom_theme)

cd(save_dir)
draw(PDF(target_file_name, 4inch, 3inch), p)
cd(current_dir)
