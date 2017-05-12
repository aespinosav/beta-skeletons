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
function save_graph_tikz(g::Graph, filename::AbstractString; bidirectional=true, standalone_doc=false)
    
    n = num_nodes(g)
    m = num_edges(g)
    
    if bidirectional
        edge_index_step = 2
    else
        edge_index_step =1
    end

    str="""\\begin{tikzpicture}
\\begin{scope}
\\tikzstyle{every node}=[draw=none,fill=none]"""

    for i in 1:n
        x, y = g.nodes[i].pos
        str *= "\\coordinate ($i) at ($(x*5.0),$(y*5.0));\n"
    end

    str *= "\\end{scope}\n"
    str *= "\\begin{scope}\n\n"

    for j in 1:edge_index_step:m
        edge = g.edges[j]
        s = edge.source.index
        t = edge.target.index
        str *= "\\draw ($s) -- ($t);\n"
    end

    str *= "\\end{scope}\n"
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
