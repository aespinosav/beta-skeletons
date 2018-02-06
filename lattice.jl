#File contains functions for generating a perturbed lattice with perturbation parameter α
using TrafficNetworks

"""
Returns the indices i,j of the position of the k-th point in the lattice
"""
function indices_of_lattice_point(k, n_root) 
        i = floor(k/n_root) # which row (from top to bottom) 0-start I think
        j = mod(k, n_root)
        indices = [Int(i),Int(j)]
end

#"""
#Make rectangular lattice of (n_root)^2 points in an (a x a) square.
#The clearance is the padding between the "outer" points of the lattice
#and the unit (a) square boundary.
#"""
#function square_lattice(n_root, a=1)#; clearance=0.05)
#    n = n_root^2
#    clearance = (a/n)*0.5
#    gap = (a - 2*clearance) / (n_root - 1)
#    
#    points = Array{Float64,1}[]
#    for k in 0:n-1
#        i, j = indices_of_lattice_point(k, n_root)
#        p_k = [clearance + (j*gap), clearance + (i*gap)]
#        push!(points, p_k)
#    end
#    points
#end

"""
Make rectangular lattice of (n_root)^2 points in an (a x a) square.
The clearance is the padding between the "outer" points of the lattice
and the unit (a) square boundary.
"""
function square_lattice(n_root, a=1)
    n = n_root^2
    clearance = (a/n)*0.5 
    gap = (a - 2*clearance) / (n_root - 1)
   
    points  = Array{Float64}(n,2)
    for k in 0:n-1
        i, j = indices_of_lattice_point(k, n_root)
        p_k = [clearance + (j*gap), clearance + (i*gap)]
        points[k+1,:] = p_k
    end
    points
end


#function corners(p, α)
#    c = Array{Float64,1}[[0.0, 0.0],
#                         [1.0, 0.0],
#                         [1.0, 1.0],
#                         [0.0, 1.0]]
#
#    κ = Array{Float64,1}[]
#    for i in 1:4
#        κ_i = p + α*(c[i] - p)
#        push!(κ, κ_i)
#    end
#    κ
#end


"""
Returns an array of the corners of the rectangle for which a uniformly
distributed point will be placed that correspnds to the lattice point p
once it has been perturbed.

Returns an array of points, that are the points in anticlockwise order
starting at the bottom left corner.

For α = 0 all the corners coincide with p. For α = 1 the corners coincide
coincide with the corners of the unit square.
"""
function corners(p, α)
    c = [0.0  0.0;
         1.0  0.0;
         1.0  1.0;
         0.0  1.0]

    k = Array{Float64}(4,2)
    for i in 1:4
        k[i,:] = p + α*(c[i,:][:] - p)
    end
    k
end

"""
Genereates a uniformly random point inside the rectangle defined by the four
points given as the corners array. (if not square it might not stretched a bit)

This should be an Array{Array{Float64,1},1}
"""
function drop_point(corner_array)
    xmin = corner_array[1,1]
    xmax = corner_array[2,1]
    ymin = corner_array[1,2]
    ymax = corner_array[4,2]

    xlength = xmax - xmin
    ylength = ymax - ymin

    x = rand()*xlength
    y = rand()*ylength
    
    p = [x,y] + corner_array[1,:][:]
end

"""
Returns a set of perturbed lattice points. For α=0 a square lattice is generated.
For α=1 a set of uniformly distribued random points.

clear is the argument passed to square_lattice as clearance from the edge of the
unit square.
"""
function α_set(n_root, α)#; clear=0.05)
    n = n_root^2
    lattice_points = square_lattice(n_root)#, clearance=clear)
    
    if α == 0.0
        points = lattice_points
    else
        points = Array{Float64}(n,2)
        for i in 1:n
            k = corners(lattice_points[i,:][:], α)
            points[i,:] = drop_point(k)
        end
    end
    points
end

"""
Makes a graph object with the nodes and their positions, but no edges.
They can be connected later (this is useful to make different networks from the same point set)
"""
function edgeless_graph(points)
    n = length(points)
    g = Graph()

    for i in 1:n
         add_node!(g, Node(i, points[i]))
    end
    g
end
