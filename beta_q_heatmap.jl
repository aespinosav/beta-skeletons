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

#Get array of graph_ids
id_array = unique(data[:graph_id])
num_graphs = length(id_array)

#Get demand range assumes equal step sizes
min_q = minimum(data[:q])
max_q = maximum(data[:q])
q_step = data[find(x-> x==id_array[1], data[:graph_id]),:][:q][2] - data[find(x-> x==id_array[1], data[:graph_id]),:][:q][1]
q_range = collect(min_q:q_step:max_q)

#Empty data frame for plotting (this is most likely the worst way of doing this)
new_data = DataFrame(β=Array{Float64,1}(), 
                     q=Array{Float64,1}(),
                     poa=Array{Float64,1}(),
                     poa_std=Array{Float64,1}())

β_max = 0
β_min = 40 
for id in id_array

    #Get indices for current graph from the DataFrame
    idxs_1 = find(x -> x==id, data[:graph_id]) 
    β = float(split(id, 'g')[1][2:end])
    
    #Keep track of β, in theory this might not be needed since I should know what data I'm loading...
    if β > β_max
        β_max = β
    elseif β < β_min
        β_min = β
    end

    for q in q_range
        #Get indices for current demand value
        idxs_2 = find(x -> x==q, data[:q])
        
        #Mean of runs for different ods for current demand value (with std)
        poa, poa_std = mean_and_std(data[intersect(idxs_1, idxs_2),:][:poa])

        row = DataArray{Float64,1}([β, q, poa, poa_std])
        push!(new_data, row)
    end
end


#labels
xlabel = "Demand (q)"
ylabel = "β"

#Name of file to save pdf plot as
target_file_name = "beta_q_heatmap.pdf"

#Custom theme for adjusting fontsize and things
custom_theme = Theme(plot_padding=0.1inch,
                     major_label_font_size=9pt,
                     minor_label_font_size=6pt)

#Configure xticks and yticks
min_poa = 1.0
max_poa_data = maximum(new_data[:poa])
max_poa_theoretical = 4.0/3.0 #For affine cost functions

q_ticks = collect(min_q:20*q_step:max_q)

β_step = (β_max - β_min)/2.0
β_ticks =collect(β_min:β_step:β_max) 

#plot the damn graph
p = plot(new_data,
         x=:q,
         y=:β,
         color=:poa,
         Scale.color_continuous(minvalue=1.0),
         Geom.rectbin,
         Guide.XLabel(xlabel),
         Guide.YLabel(ylabel),
         Guide.xticks(ticks=q_ticks),
         Guide.yticks(ticks=β_ticks),
         custom_theme)

cd(save_dir)
cd(current_dir)
