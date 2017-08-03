using Colors

"""
Saves a .tex file that contains a tikz image. Currently it generates an article document in LaTeX.
Usage is as follows:

save_graph_tikz(g, filename)

Where g is a Graph and filename is a the name of the target file as a string.

This function assumes that for all connected nodes, there are edges in both directions and that their 
indices are consecutive. That is, evens go one way, odds the other (in no particular preference).
If network is truley a directed graph then it MUST be specified.

The optional variable 'standalone_doc' can be set to true if  the diagram is to be rendered by itself
as a pdf document.
"""
function save_graph_tikz(g::Graph, filename::AbstractString; bidirectional=true, standalone_doc=true)
    scale = 10.0
    n = num_nodes(g)
    m = num_edges(g)
    
    if bidirectional
        edge_index_step = 2
    else
        edge_index_step =1
    end

    str="""\\begin{tikzpicture}
\\begin{scope}
\\tikzstyle{every node}=[draw=none,fill=none]\n"""

    for i in 1:n
        x, y = g.nodes[i].pos
        str *= "\\coordinate ($i) at ($(x*scale),$(y*scale));\n"
    end

    str *= "\\end{scope}\n"
   
    str *="""\\begin{scope}
  \\draw[gray,thin,dashed] (0,0) rectangle ($(scale),$(scale));
  \\end{scope}\n"""

    if m != 0   #If there are no edges, adding an empty scope is likely to cause problems
        str *= "\\begin{scope}\n\n"

        for j in 1:edge_index_step:m
            edge = g.edges[j]
            s = edge.source.index
            t = edge.target.index
            str *= "\\draw ($s) -- ($t);\n"
        end

        str *= "\\end{scope}\n"
    end

    str*=
        """
        \\end{tikzpicture}"""

    if standalone_doc
        head = """\\documentclass{article}
\\usepackage{tikz}
\\usepackage[active,tightpage]{preview}
\\PreviewBorder=2pt
\\PreviewEnvironment{tikzpicture}
\\begin{document}"""
        tail = "\n\\end{document}"

        str = head *str* tail
    end

    open(filename, "w") do f
        write(f, str)
    end
end


function plot_flows_net(filename, g, flows; tol = 1e-4)

    scale = 10.0
    n = num_nodes(g)
    m = num_edges(g)

    min_flow = minimum(flows)
    max_flow = maximum(flows)

    cmap = colormap("Oranges") #Defines 100 colors

    edge_index_step =1

    str="""\\begin{tikzpicture}
\\begin{scope}
\\tikzstyle{every node}=[draw=none,fill=none]\n"""

    for i in 1:n
        x, y = g.nodes[i].pos
        str *= "\\coordinate ($i) at ($(x*scale),$(y*scale));\n"
    end

    str *= "\\end{scope}\n"
   
    str *="""\\begin{scope}
  \\draw[gray,thin,dashed] (0,0) rectangle ($(scale),$(scale));
  \\end{scope}\n"""

    if m != 0   #If there are no edges, adding an empty scope is likely to cause problems
        str *= "\\begin{scope}\n\n"

        for j in 1:edge_index_step:m
            value = flows[j]
            
            if value > tol
                edge = g.edges[j]
                idx = Int(ceil((value / (max_flow+0.0000000000000001))*100))
                edge_color = cmap[idx]
                color_str = "{rgb,255:red,$(edge_color.r*255);green,$(edge_color.g*255);blue,$(edge_color.b*255)}"

                s = edge.source.index
                t = edge.target.index

                str *= "\\draw[->,color=$(color_str),thick] ($s) -- ($t);\n"
            end
        end

        str *= "\\end{scope}\n"
    end

    str*=
        """
        \\end{tikzpicture}"""

    head = """\\documentclass{article}
\\usepackage{tikz}
\\usepackage[active,tightpage]{preview}
\\PreviewBorder=2pt
\\PreviewEnvironment{tikzpicture}
\\begin{document}"""
    tail = "\n\\end{document}"

    str = head *str* tail

    open(filename, "w") do f
        write(f, str)
    end
end






function save_graph_tikz_circ(g::Graph, filename::AbstractString; bidirectional=true, standalone_doc=true)
    
    n = num_nodes(g)
    m = num_edges(g)
    
    if bidirectional
        edge_index_step = 2
    else
        edge_index_step =1
    end

    str="""\\begin{tikzpicture}
\\begin{scope}\n\\tikzstyle{every node}=[draw,circle,fill=black,minimum size=3pt]\n"""

    for i in 1:n
        x, y = g.nodes[i].pos
        str *= "\\node ($i) at ($(x*5.0),$(y*5.0)) {};\n"
    end

    str *= "\\end{scope}\n"
    

    if m != 0   #If there are no edges, adding an empty scope is likely to cause problems
        str *= "\\begin{scope}\n\n"

        for j in 1:edge_index_step:m
            edge = g.edges[j]
            s = edge.source.index
            t = edge.target.index
            str *= "\\draw ($s) -- ($t);\n"
        end

        str *= "\\end{scope}\n"
    end

    str*=
        """
        \\end{tikzpicture}"""

    if standalone_doc
        head = """\\documentclass{minimal}
\\usepackage{tikz}
\\begin{document}"""
        tail = "\n\\end{document}"

        str = head *str* tail
    end

    open(filename, "w") do f
        write(f, str)
    end
end
