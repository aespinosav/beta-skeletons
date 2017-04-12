#Functions for the generation of the perturbed-lattice

#Lattice parameters (these are handles for future extensions to ohter lattice-types)
#Tetragonal square lattice
e1 = [1.0,0.0]
e2 = [0.0,1.0]
#Scales are later adjusted 
a = b = 1.0

n_root = 10
n = n_root^2


"""
Returns the indices i,j of the position of the k-th point in the lattice
"""
function indices_of_lattice_point(k, n_root) 
        i = floor(k/n_root) # which row (from top to bottom) 0-start I think
        j = mod(k, n_root)

        indices = [i,j]
end


"""
Make rectangular lattice of (n_root)^2 points in an (a x a) square.
The clearance is the padding between the "outer" points of the lattice
and the unit (a) square boundary.
"""
function square_lattice(n_root, a=1, clearance=0.05)
    n = n_root^2
    gap = (a - 2clearance) / (n-1)
    
    points = Array{Float64,1}[]
    for k in 1:n
        i, j = indices_of_lattice_point(k, n_root)
        p_k = [clearance + (j*gap), clearance + (i*gap)]
        push!(points, p_k)
    end
    points
end

"""
Returns an array of the corners of the rectangle for which a uniformly
distributed point will be placed that correspnds to the lattice point p
once it has been berturbed.

Returns an array of points, that are the points in anticlockwise order
starting at the bottom left corner.

For α = 0 all the corners coincide with p. For α = 1 the corners coincide
coincide with the corners of the unit square.
"""
function corners(p, α)
    
    c = Array{Float64,1}[[0.0, 0.0],
                         [1.0, 0.0],
                         [1.0, 1.0],
                         [0.0, 1.0]]

    κ = Array{Float64,1}[]
    for i in 1:4
        κ_i = p + α*(c[i] - p)
        push!(κ, κ_i)
    end
    κ
end

"""
Genereates a uniformly random point inside the rectangle defined by the four
points given as the corners array.

This scales a unit square, so perhaps it messes with the distribution (non-isotropic)

This should be an Array{Array{Float64,1},1}
"""
function drop_point(corners)
    xmin = corners[1][1]
    xmax = corners[2][1]
    ymin = corners[1][2]
    ymax = corners[4][2]

    xlength = xmax - xmin
    ylength = ymax - ymin

    x = rand()*xlength + xmin
    y = rand()*ylength + ymin
    
    p = [x,y]
end


"""
Returns a set of perturbated? lattice points. For α=0 a square (rectangular) lattice is generated.
For α=1 a set of uniformly distribued random points
"""
function α_set(n_root, α)
    n = n_root^2
    lattice_points = square_lattice(n_root)
    
    if α == 0.0
        return lattice_points
    else
        points = Array{Float64,1}[]
        for p in lattice_points
            corn = corners(p, α)
            actual_point = drop_point(corn)
            push!(points, actual_point)
        end
        return points    
    end
end
