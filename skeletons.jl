#Script to generate beta skeletons (eventually to be turned into a module)...
# implementation of the algorithm (right beta region) of Hurtado et al. 2003 comp. geometry 25.



#Define functions
"""
Returns the quadrant in which the point pt lives
"""
function quadrant(pt)
    s = sign(pt)
    if s[1] > 0
        if s[2] > 0
            return 1 # both pos -> first quadrant
        else
            return 4 # x pos, y neg -> quadrant
        end
    else # in left semiplane
        if s[2] > 0
            return 2
        else
            return 3
        end
    end
end

function angle_for_rotation(pt)
    q = quadrant(pt)

    x, y = pt

    if q == 1
        angle = -acos(x/ norm(pt))
    elseif q==2
        angle = -(pi/2 + acos(y/norm(pt)))
    elseif q==3
        angle = -(pi + acos(-x/norm(pt)))
    elseif q==4
        angle = -(3pi/2 + acos(-y/norm(pt)))
    end
    return angle
end


function rotate_points(list_of_points, theta)
    c = cos(theta)
    s = sin(theta)

    mat = [c -s;
           s  c]

    map(x -> mat*x, list_of_points)
end

function polar_angle(pt)
    q = quadrant(pt)
    delta = [0, pi, pi, 2pi]

    angle = atan(pt[2]/pt[1]) + delta[q]
end


function incr_1(p, u, v, beta) #checks if p is in right beta region of u,v
    # centre has to be to the right

    vect = v - u
    mag = norm(v - u)
    perp = [-vect[2], vect[1]]

    r = mag/beta

    c = u + 0.5*vect + sqrt(r^2 - (mag^2)/4)*perp/mag

    onright = sign(dot(perp, c)) >= 0
    incircle = norm(p - c) <= r

    onright && incircle
end

# Alg start



n = 5# number of nodes (uniformly distributed in the unit square to begin with)
beta = 0.5 #beta parameter for beta skeleton

points = rand(n, 2)

#Algorithm: Rigth beta-region


#Ordered list of remaining points for each point
ordered_lists_of_points = Dict{Int, Array{Int,1}}()
for i in 1:n

    new_points = [points[j,:] - points[i,:] for j in 1:n]                    #Recentre the points around p_i
    distances = map(norm, new_points)                                       #distances between all points
    distances[i] = Inf                                                      #Set this to avoid conflicts...
    first_point = findmin(distances)[2]                                     #Find the first point (radially closest)
    first_angle = polar_angle(new_points[first_point])                      #Find polar angle of first_point

    angles_of_the_points = zeros(n)
    for j in 1:i-1
        angles_of_the_points[j] = polar_angle(new_points[j])
    end
    for j in i+1:n
        angles_of_the_points[j] = polar_angle(new_points[j])
    end
    angles_of_the_points[i] = -Inf

    map!(x -> mod((x - first_angle), 2pi) , angles_of_the_points)               #Subtract angle of first point to all of them, modulo 2pi

    order = sortperm(angles_of_the_points, rev=true)
    ordered_points_for_p_i = [first_point;order[2:end-1]]
    ordered_lists_of_points[i] = ordered_points_for_p_i
end

for i in 1:n

end
