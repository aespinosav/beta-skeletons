using TrafficNetworks, SkeletonCities, DataFrames

#File system settings

top_dir = "/space/ae13414/Data/alfa-beta"
cd(top_dir)
mkdir(string(now()))

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

#Script run

for a in α_range
    for b in β_range

        g = skeleton_graph_αβ(n_points, a, b)
        g_id = ""

        rn = road_network_from_geom_graph(g)

    end
end
