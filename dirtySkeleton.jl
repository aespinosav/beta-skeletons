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

    onright = sign(dot(perp, p - u)) >= 0
    incircles = norm(p - c1) < r && norm(p - c2) < r
end

"""
Returns a beta-skeleton graph with n points for parameter beta
"""
function beta_skeleton(n, beta)

    if beta <= 1        # This should be in short-circuit form to be idiomatic
        in_C = in_C_1
    else
        in_C = in_C_2
    end

    xs = rand(n)
    ys = rand(n)

    g = Graph()

    for i in 1:n
        pos = [xs[i], ys[i]]
        add_node!(g, Node(i, pos))
    end

    for i in 1:n
        for j in i+1:n

            isempty = true

            for k in 1:n
                if i != k && j !=k

                    p = g.nodes[k].pos
                    u = g.nodes[i].pos
                    v = g.nodes[j].pos

                    if in_C(p,u,v,beta)
                        isempty = false
                        break
                    end
                end
            end

            if isempty
                connect!(g, i, j)
                connect!(g, j, i)
            end

        end
    end
    return g    #Should just have g, but its easier to read this way...
end