using TrafficNetworks

function skeleton_road_network(n, beta, od, b_mult=1.4)
    g = beta_skeleton(n, beta)

    a_params = Array{Float64,1}()
    b_params = Array{Float64,1}()

    for i in 1:num_edges(g)

        dist = norm(g.edges[i].target.pos - g.edges[i].source.pos)
        a = dist #this can be changed to introduce noise (should do...)
        b = rand()*b_mult*a # This can also be changed...

        push!(a_params, a)
        push!(b_params, b)
    end
    rn = RoadNetwork(g, a_params, b_params, od)
end
