using TrafficNetworks, SkeletonCities, DataFrames

#File system settings

top_dir = "/space/ae13414/Data/alfa-beta"
cd(top_dir)
writing_dir = string(now()) #Make dir with date and time to store data
mkdir(writing_dir)
cd(writing_dir)

#Simulation parameters

α_range = 0.0:0.1:1.0
β_range = 1.0:0.1:2.0
q_range = 0.1:0.1:1.0

n_points = 100
od_samples = 1000

#Calculate run-specific iters

n_nets = α_range * β_range
staps_to_solve_per_net = q_range * od_samples
staps_to_solve_total = n_nets * staps_to_solve_per_net

#Write PARAMS file

f = open("run_info.md", "w")
param_string =
"""
Simulation run on $writing_dir
==============================

α range = $α_range
β range = $β_range
q range = $q_range

Network size             = $n_points
OD samples (per network) = $od_samples
Number of networks       = $n_nets


Total STAPs to solve (nets * demand_values * od_samples per net) = $staps_to_solve_total
"""
write(f, param_string)
close(f)


#Script run


data_frame = DataFrame(graph_id=Array{UTF8String,1}(),
                            od=Array{Tuple{Int64,Int64},1}(),
                            β=Array{Float64,1}(),
                            q=Array{Float64,1}(),
                            uecost=Array{Float64,1}(),
                            socost=Array{Float64,1}(),
                            poa=Array{Float64,1}())

for a in α_range
    for b in β_range

        g = skeleton_graph_αβ(n_points, a, b)
        g_id = ""

        rn = road_network_from_geom_graph(g)

    end
end
