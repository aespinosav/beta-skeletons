# Script generates cities based on beta skeletons. An ensemble of cities are generated for each value of the paramater beta
# specified in a given range. For each value of beta, a dir is made for the ensemble

using TrafficNetworks, SkeletonCities

#dir = "./Data"   # Directory to write data files to

cities_per_ensemble = 100
nodes_per_city = 100
beta_range = 1:0.1:1.9

#cd("./Data")
for b in 1.0:0.1:1.9

    current_dir = pwd()
    dir_name = @sprintf "/beta_%1.2f" b
    mkdir(current_dir * dir_name)

    cd("."*dir_name)
        for i in 1:cities_per_ensemble
            st = "g"*"%0$(length(digits(cities_per_ensemble)))d"*"_beta_%1.2f"
            file_name = @eval @sprintf($st, $i, $b) # nasty wizardry...
            g = beta_skeleton(nodes_per_city, b)
            save_graph(g, file_name*".json")
        end
    cd("..")

end