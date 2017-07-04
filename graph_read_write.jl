using JSON

#Functions to write and load graphs in json format
function save_graph(g, filename; params...)

    N = num_nodes(g)
    M = num_edges(g)

    header = """{\n"""

    header *= """ "num_nodes": $N,\n"""
    header *= """ "num_edges": $M,\n"""

    has_coordinates = length(g.nodes[1].pos) != 0
    header *= """ "hasCoordinates": $(has_coordinates),\n"""

    for p in params
        header *= """ "$(string(p[1]))": $(p[2]),\n"""
    end

    open(filename, "w") do f
        write(f, header)
        write(f, """ "nodes": [\n""")

        for i in 1:N-1
            write(f, """  {\n   "index": $(g.nodes[i].index),\n   "pos": $(g.nodes[i].pos)\n  },\n""")
        end
        write(f, """  {\n   "index": $(g.nodes[N].index),\n   "pos": $(g.nodes[N].pos)\n  }\n""")
        write(f, " ],\n")
        write(f, """ "edges": [\n""")

        for i in 1:M-1
            write(f, """  {\n   "index": $(g.edges[i].index),\n   "source": $(g.edges[i].source.index),\n   "target": $(g.edges[i].target.index)\n  },\n""")
        end
        write(f, """  {\n   "index": $(g.edges[M].index),\n   "source": $(g.edges[M].source.index),\n   "target": $(g.edges[M].target.index)\n  }\n""")
        write(f, " ]\n")
        write(f, "}")
    end
end

function load_graph(filename)
    d = JSON.parsefile(filename)

    N = d["num_nodes"]
    M = d["num_edges"]

    g = Graph()

    if d["hasCoordinates"]
        for i in 1:N
            idx = d["nodes"][i]["index"]
            pos = d["nodes"][i]["pos"]
            add_node!(g, Node(idx, pos))
        end
    else
        pos = Float64[]
        for i in 1:N
            idx = d["nodes"][i]["index"]
            add_node!(g, Node(idx, pos))
        end
    end

    for j in 1:M
        s = d["edges"][j]["source"]
        t = d["edges"][j]["target"]
        connect!(g, s, t)
    end
    g
end

"""
Loads a road network from data files. Requires two files: A json file and a param file
"""
function load_road_network(filename)
    g_id = split(filename, ".json")[1]
    g = load_graph(filename)
    pars = readdlm(g_id*".params")
    a = pars[:,1]
    b = pars[:,2]
    rn = RoadNetwork(g, a, b)
end


# This function is no longer being used as graphviz is a bit too unstable to changing scales and things
function save_graph_dot(g, filename, name="G", scale=1)

    str = "digraph $(name) {\nconcentrate=true;\n"
    str *= """node [shape=circle, label="", fixedsize=true, width=5, style=filled, fillcolor=black];\n"""
    str *= """edge [penwidth=5];\n\n"""

    open(filename, "w") do f
        write(f, str)
        for i in 1:num_nodes(g)
            x, y = g.nodes[i].pos[1], g.nodes[i].pos[2]
            X, Y = round(Int, x*1000), round(Int, y*1000) #coords in graphviz are to 1/72 of an inch
            write(f, """$i [pos="$(X),$(Y)!"];\n""")
        end

        for j in 1:num_edges(g)
            s, t = g.edges[j].source.index, g.edges[j].target.index
            write(f, "$s -> $t;\n")
        end
        write(f, "}")
    end
end
