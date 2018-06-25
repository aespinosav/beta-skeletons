using TrafficNetworks

"""
Checks if point 'p' is in the circle based region of points u and v
for given beta <= 1
"""
function in_C_1(p, u, v, beta)
    vect = v - u
    mag = norm(vect)
    perp = [-vect[2], vect[1]]

    d = mag/beta
    r = 0.5*d

    c1 = u + 0.5*vect + sqrt(r^2 - (mag^2)/4)*(perp/mag)
    c2 = u + 0.5*vect - sqrt(r^2 - (mag^2)/4)*(perp/mag)

    incircle_1 = norm(p - c1) < r
    incircle_2 = norm(p - c2) < r

    incircle_1 && incircle_2
end

"""
Checks if point 'p' is in the lune based region of points u and v,
for beta > 1.
"""
function in_C_2(p, u, v, beta)

    vect = v - u
    mag = norm(vect)

    unit_vect = vect/mag    #Unit vector that points from u -> v.

    perp = [-vect[2], vect[1]]

    r = beta*mag*0.5

    c1 = v - r*unit_vect    #Centre of circle that has u in its interior
    c2 = u + r*unit_vect    #Centre of circle that has v in its interior

    onright = sign(dot(perp, p - u)) > 0
    incircles = norm(p - c1) < r && norm(p - c2) < r
end



"""
Makes a beta skeleton from a set of points given as a 2D array of coordinates.

Default is for set of points to be given as a 2D array.
Array of arrays also has a defined method.
"""
function β_skeleton(points::Array{Float64,2}, β)
    
    n = size(points)[1]
    g = Graph()

    for i in 1:n
        add_node!(g, Node(i, points[i,:][:]))
    end
    
    if β <= 1
        in_C = in_C_1
    else
        in_C = in_C_2
    end

    for i in 1:n
        for j in i+1:n
            isempty = true

            for k in 1:n
                if i != k && j !=k
                    p = g.nodes[k].pos
                    u = g.nodes[i].pos
                    v = g.nodes[j].pos

                    if in_C(p,u,v,β)
                        isempty = false
                        break
                    end
                end
            end

            if isempty
                connect_net!(g, i, j)
                connect_net!(g, j, i)
            end
        end
    end
    g
end

# If given an array of arrays
function β_skeleton(points::Array{Array{Float64,1},1}, β)
    new_points = Array{Float64}(length(points),2)
    for i in 1:length(points)
        new_points[i,:] = points[i]
    end
    β_skeleton(new_points, β)
end
