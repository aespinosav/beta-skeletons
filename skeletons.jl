#Script to generate beta skeletons (eventually to be turned into a module)...
# implementation of the algorithm (right beta region) of Hurtado et al. 2003 comp. geometry 25.



#Define functions
"""
Returns the quadrant in which the point pt lives in
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

# function angle_for_rotation(pt)
#     q = quadrant(pt)
# 
#     x, y = pt
# 
#     if q == 1
#         angle = -acos(x/ norm(pt))
#     elseif q==2
#         angle = -(pi/2 + acos(y/norm(pt)))
#     elseif q==3
#         angle = -(pi + acos(-x/norm(pt)))
#     elseif q==4
#         angle = -(3pi/2 + acos(-y/norm(pt)))
#     end
#     return angle
# end


# function rotate_points(list_of_points, theta)
#     c = cos(theta)
#     s = sin(theta)
# 
#     mat = [c -s;
#            s  c]
# 
#     map(x -> mat*x, list_of_points)
# end

"""
Retruns the polar angle of the point pt.

Measured counterclockwise from the x-axis.
"""
function polar_angle(pt)
    q = quadrant(pt)
    delta = [0, pi, pi, 2pi]
    angle = atan(pt[2]/pt[1]) + delta[q]
end

"""
Checks if point 'p' is in the right beta-region of points u and v
for given beta <= 1
"""
function in_Cr_1(p, u, v, beta) 
    # centre has to be to the right

    vect = v - u
    mag = norm(vect)
    perp = [-vect[2], vect[1]]

    d = mag/beta
    r = 0.5*d

    c = u + 0.5*vect + sqrt(r^2 - (mag^2)/4)*(perp/mag)

    onright = sign(dot(perp, p - u)) >= 0
    incircle = norm(p - c) < r

    onright && incircle
end

"""
Function that checks if the point 'p' is in the right beta-region of points u and v,
for beta > 1.
"""
function in_Cr_2(p, u, v, beta)

    vect = v - u
    mag = norm(vect)

    unit_vect = vect/mag    #Unit vector that points from u -> v.

    perp = [-vect[2], vect[1]]

    r = beta*mag*0.5

    c1 = v - r*unit_vect    #Centre of circle that has u in its interior
    c2 = u + r*unit_vect    #Centre of circle that has v in its interior

    onright = sign(dot(perp, p - u)) >= 0
    incircles = norm(p - c1) < r && norm(p - c2) < r

    onright && incircles
end


# Params for the algorithm

n = 5# number of nodes (uniformly distributed in the unit square to begin with)
beta = 0.5 #beta parameter for beta skeleton
points = rand(n, 2)



#Algorithm: Rigth beta-region

if beta <= 1            # Check at the start which function to use to check the right beta region
    in_Cr = in_Cr_1
else
    in_Cr = in_Cr_2
end

ordered_lists_of_points = Dict{Int, Array{Int,1}}()     #For each point, Ordered list of remaining points
clockwise_rel_angles = Dict{Int, Array{Float64,1}}()    #For each point, Clockwise angles to each point (in same order as above)

#Step 1
#For each point, we compile an ordered list of indices that correspond to the points
#and keep their polar angles (centred around the given point)
for i in 1:n

    new_points = [points[j,:] - points[i,:] for j in 1:n]                   #Recentre the points around p_i
    distances = map(norm, new_points)                                       #distances between all points
    distances[i] = Inf                                                      #Set this to avoid conflicts...
    first_point = findmin(distances)[2]                                     #Find the first point (radially closest) the [2] gives the index
    first_angle = polar_angle(new_points[first_point])                      #Find polar angle of first_point

    angles_of_the_points = zeros(n)
    for j in 1:i-1
        angles_of_the_points[j] = polar_angle(new_points[j])
    end
    for j in i+1:n
        angles_of_the_points[j] = polar_angle(new_points[j])
    end
    angles_of_the_points[i] = -Inf

    map!(x -> mod((x - first_angle), 2pi) , angles_of_the_points)           #Subtract angle of first point to all of them, modulo 2pi

    order = sortperm(angles_of_the_points, rev=true)
    ordered_points_for_p_i = [first_point;order[2:end-1]]                   #the ';' concatenates the arrays

    ordered_lists_of_points[i] = ordered_points_for_p_i
    clockwise_rel_angles[i] = angles_of_the_points[ordered_points_for_p_i] #Store the lists in dictionaries of the points and angles
end


#Step 2

labels_of_points_per_point = Dict{Int, Array{AbstractString,1}}()

for j in 1:n

    labels = Dict{Int, AbstractString}()
    lmi = -1
    prevMaybe = Dict{Int, Int}()

    p = points[j,:]

    for i in 1:n-1

        k = ordered_lists_of_points[j][i]               # Real index of the point p_i (within the original array points)
        kpp = ordered_lists_of_points[j][i+1]           # Real index of the point p_(i+1) (within the array points)

        p_i = points[k,:]                               # Actual point in vector form (row vector)
        p_ipp = points[kpp,:]

        if !in_Cr(p_ipp, p, p_i, beta)
            labels[i] = "Maybe"
            prevMaybe[i] = lmi
            lmi = i
        else
            labels[i] = "No"
            l = lmi
            while l >= 1 && in_Cr(p_ipp, p, points[ordered_lists_of_points[j][l],:], beta )
                l = lmi
                labels[l] = "No"
                lmi = prevMaybe[l]
            end
        end

    end
    labels_of_points_per_point[j] = labels
end

t = maximum(find(clockwise_rel_angles[i] .< pi ))
for i in 1:t
    if labels[]

