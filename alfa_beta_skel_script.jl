using TrafficNetworks, SkeletonCities, DataFrames
"""
This script generates and saves traffic simulation data for ensembles of the αβ-skeletons.
It constructs and saves the networks and saves the corresponding network and parameter files
in the given directories (se below).

The first section of this script has the configuration variables for both the file system
destinations and the paramaters and their ranges for the simulations. So anyone wanting
to use this script is encouraged to read throught the preamble (I know its a bit long...)
carefully and check that the settings for the simulation runs are as desired as they can 
take a very long time to run if too many simulations are chosen...
"""

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

α_instances = 100 #Instances of alfa sets to be made for each β
n_points = 100
od_samples = 1000

#We generate an ensemble of alfa-sets and then calculate the beta skeleton for different values of beta for each set of points in the ensemble. This way we can also keep track of how the topology of the netwrk changes with beta. (for the same set of points!)

#Calculate run-specific iters

n_nets = α_range * α_instances * β_range
staps_to_solve_per_net = q_range * od_samples
staps_to_solve_total = n_nets * staps_to_solve_per_net

#Write simulation run info file

f = open("run_info.md", "w")
info_string =
"""
Simulation run on $writing_dir
==============================

α range = $α_range
β range = $β_range
q range = $q_range

α instances = $α_instances

Network size             = $n_points
OD samples (per network) = $od_samples
Number of networks       = $n_nets


Total STAPs to solve (nets * demand_values * od_samples per net) = $staps_to_solve_total


Simulation
----------

For the above choice of parameters this script does the following:

For each value of α an ensemble of $α_insatnces perturbed lattices is generated. (randomness is involved)
From _each_ of these point sets a β-skeleton is formed for _every_ value of β.
And for each of these graphs flow function parameters are generated (semi-randomly).

For each unique road network generated this way the STAP is solved for $od_samples randomly selected _single_ OD pairis $(length(q_range)) times, which corresponds to all the demand values in the given demand range.


Naming convention and contents of files
---------------------------------------

File for the α-sets are of the form,

    - set_s000a000.dat

The numbers following the 'a' and the 's' are the velue of α and the set id (number of generated set) respectively. These files are written using 'writedlm' with tabs as separators and the object written is of type Array{Array{Float64,1},1}. i.e. an array of 2d arrays which are the points.

Files for β-seletons (generated from these α-sets) have the form,

    - skel_s000a000b000.json

the numbers after the 's' and 'a' are the same as with the α-set files. The number after the 'b' is the value of β for the skeleton. These files are JSON files that represent the graphs and are written (and can be read) using functions from The SkeletonCities module.


The files that contain the parameters of the cost functions are,

    - params_s000a000b000.dat

these files just have an hcat of the a and b parameter vectors. They are written usign writedlm and can be read along with the skeleton files to make a RoadNetwork (from TrafficNetworksw module).

"""
write(f, info_string)
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
    for na in 1:α_instances
        set = α_set(10, a)
        writedlm("set_s$(na)_a$(a).dat" , set)
        for b in β_range
            g = β_skeleton(set, b)
            g_id = "skel_s$(na)_a$(a)_b$(b)"
            save_graph(g, g_id*".json")
            rn = road_network_from_geom_graph(g)
            writedlm(g_id*".params", hcat(rn.a, rn.b), header="Flow params: a, b")
            num_od_pairs = 0.1*num_nodes^2 #sample 10 percent of od pairs
            od_list = od_pairs(g, num_od_pairs)
            
            for (i, od) in enumerate(od_list)
                od_mat = od_matrix_from_pair(rn.g, od)
                sols_ue = ta_solve(rn, OD, demand_range)
                sols_so = ta_solve(rn, OD, demand_range, regime="SO")

                data_ue = flows_data_frame(sols_ue, demand_range)
                data_so = flows_data_frame(sols_so, demand_range)
            end

            for k in 1:length(demand_range)

                f_ue = data_ue[k, 2:end]
                f_so = data_so[k, 2:end]

                cost_ue = tot_cost(rn, data_ue[k,:])
                cost_so = tot_cost(rn, data_so[k,:])

                poa = cost_ue/cost_so

                row = data([id; od; β; k; cost_ue; cost_so; cost_ue/cost_so])
                push!(data_frame, row)
            end
        end
    end
end
