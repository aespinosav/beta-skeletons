using Colors

"""
Saves a .tex file that contains a tikz image. Currently it generates an article document in LaTeX.
Usage is as follows:

    `save_graph_tikz(g, filename)`

Where g is a Graph and filename is a the name of the target file as a string.

This function assumes that for all connected nodes, there are edges in both directions and that their 
indices are consecutive. That is, evens go one way, odds the other (in no particular preference).
If network is truley a directed graph then it MUST be specified.

The optional variable 'standalone_doc' can be set to true if  the diagram is to be rendered by itself
as a pdf document.
"""
function save_graph_tikz(g, filename; bidirectional=true, standalone_doc=true, log_scale=false)

    scale = 10

    n = num_nodes(g)
    m = num_edges(g)
    
    #This is only asking for trouble
    if bidirectional
        edge_index_step = 2
    else
        edge_index_step = 1
    end


    #Begin tikz picture

    str="\n\\begin{tikzpicture}\n"
    
    #Begin node scope (toggle comment for nodes or no nodes)
    str *= "\\begin{scope}\n\\tikzstyle{every node}=[draw=none,fill=none,inner sep=0]\n"
#    str *= "\\begin{scope}\n\\tikzstyle{every node}=[draw,circle,fill=gray,minimum size=0.1cm]\n"
    for i in 1:n
        x, y = g.nodes[i].pos
        str *= "\\node ($i) at ($(x*scale),$(y*scale)) {};\n"
    end
    str *= "\\end{scope}\n"
    
    #Begin dashed frame scope
    str *="\\begin{scope}\n\\draw[gray,thin,dashed] (0,0) rectangle ($(scale),$(scale));\n\\end{scope}\n"
    
    #Begin edge scope
    if m != 0   #If there are no edges, adding an empty scope is likely to cause problems
        str *= "\\begin{scope}\n\n"
        for j in 1:edge_index_step:m
            edge = g.edges[j]
            s = edge.source.index
            t = edge.target.index
            str *= "\\draw[thick] ($s) -- ($t);\n"
        end
        str *= "\\end{scope}\n"
    end
    
    #End tikzpicture
    str*="\\end{tikzpicture}"

    #Add header and footer to file
    if standalone_doc
    
        head = """
                  \\documentclass{article}
                  \\usepackage{tikz}
                  \\usepackage[active,tightpage]{preview}
                  \\PreviewBorder=2pt
                  \\PreviewEnvironment{tikzpicture}
                  \\begin{document}\n"""
                  
        tail = "\n\\end{document}"
        str = head *str* tail
    end

    #Write figure
    open(filename, "w") do f
        write(f, str)
    end
end


function save_graph_tikz_bend(g, filename::AbstractString; bidirectional=false, standalone_doc=true, log_scale=false)
    scale = 1
    n = num_nodes(g)
    m = num_edges(g)
    
    if bidirectional
        edge_index_step = 2
    else
        edge_index_step = 1
    end

    #Begin tikz picture
    str="""\\begin{tikzpicture}
           \\tikzset{edge/.style = {->,> = latex'}}\n"""
    #Begin node scope
    
    str *= "\\begin{scope}\n\\tikzstyle{every node}=[draw,circle,fill=black,inner sep=0pt,outer sep=0pt,minimum size=0.1cm]\n"
    for i in 1:n
        x, y = g.nodes[i].pos
        str *= "\\node ($i) at ($(x*scale),$(y*scale)) {};\n"
    end
    str *= "\\end{scope}\n"
    #Begin dashed frame scope
    str *="\\begin{scope}\n\\draw[gray,thin,dashed] (0,0) rectangle ($(scale),$(scale));\n\\end{scope}\n"
    #Begin edge scope
    if m != 0   #If there are no edges, adding an empty scope is likely to cause problems
        str *= "\\begin{scope}\n\n"
        for j in 1:edge_index_step:m
            edge = g.edges[j]
            s = edge.source.index
            t = edge.target.index
            str *= "\\draw[edge] ($s) to[bend left] ($t);\n"
        end
        str *= "\\end{scope}\n"
    end
    #End tikzpicture
    str*="\\end{tikzpicture}"

    #Add header and footer to file
    if standalone_doc
        head = """
                  \\documentclass{article}
                  \\usepackage{tikz}
                  \\usetikzlibrary{arrows}
                  \\usepackage[active,tightpage]{preview}
                  \\PreviewBorder=2pt
                  \\PreviewEnvironment{tikzpicture}
                  \\begin{document}\n"""
        tail = "\n\\end{document}"
        str = head *str* tail
    end

    #Write figure
    open(filename, "w") do f
        write(f, str)
    end
end


function plot_flows_net(filename, g, flows; tol = 1e-5,log_scale=false)

    scale = 10
    
    n = num_nodes(g)
    m = num_edges(g)

    min_flow = minimum(flows)
    max_flow = maximum(flows)

    cmap = (log_scale) ? colormap("Oranges") : colormap("Oranges", logscale=true)   #Defines 100 colors
    edge_index_step = 1    

    # Set background color
    str = "\\usetikzlibrary{backgrounds}\n"
    #Begin tikz picture
    str *= "\\begin{tikzpicture}background rectangle/.style={fill=gray!50}, show background rectangle]\n\n% Scale  1:$(scale)\n\n"
    #Begine node scope
    str *="\\begin{scope}\n"
    node_format = "\\tikzstyle{every node}=[draw=none,fill=none]\n"
    str *= node_format
    for i in 1:n
        x, y = g.nodes[i].pos
        str *= "\\coordinate ($i) at ($(x*scale),$(y*scale));\n"
    end
    str *= "\\end{scope}\n"
    #Begin frame scope
    str *="""\\begin{scope}
             \\draw[gray,thin,dashed] (0,0) rectangle ($(scale),$(scale));
             \\end{scope}\n"""
    #Begin edge scope
    if m != 0   #There should be edges but just in case...
        str *= "\\begin{scope}\n\n"
        for j in 1:edge_index_step:m
            value = flows[j]
            
            if value > tol
                edge = g.edges[j]
                idx = Int(ceil((value / (max_flow+0.0000000000000001))*100)) #index for colormap
                edge_color = cmap[idx]
                color_str = "{rgb,255:red,$(edge_color.r*255);green,$(edge_color.g*255);blue,$(edge_color.b*255)}"

                s = edge.source.index
                t = edge.target.index

                str *= "\\draw[->,color=$(color_str),thick] ($s) -- ($t);\n"
            end
        end

        str *= "\\end{scope}\n\n"
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


function plot_flows_net_cbar(filename, g, flows; tol = 1e-5,log_scale=false)

    scale = 10.0 #There has to be a better way of doing this...
    
    n = num_nodes(g)
    m = num_edges(g)

    min_flow = minimum(flows)
    max_flow = maximum(flows)


    cmap = (log_scale) ? colormap("Oranges") : colormap("Oranges", logscale=true)   #Defines 100 colors
    #is this the wrong way around?
    edge_index_step = 1
    
    #Begin tikz picture
    str="\\begin{tikzpicture}\n% Scale  1:$(scale)"
    #Begine node scope
    str *="\\begin{scope}\n"
    node_format = "\\tikzstyle{every node}=[draw=none,fill=none]\n"
    str *= node_format
    for i in 1:n
        x, y = g.nodes[i].pos
        str *= "\\coordinate ($i) at ($(x*scale),$(y*scale));\n"
    end
    str *= "\\end{scope}\n"
    #Begin frame scope
    str *="""\\begin{scope}
             \\draw[gray,thin,dashed] (0,0) rectangle ($(scale),$(scale));
             \\end{scope}\n"""
    #Begin edge scope
    if m != 0   #There should be edges but just in case...
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
    
    #Begin colourbar scope
    str *= """%Colourbar scope
              \\begin{scope}[shift={(0,-1)}]
              \\pgfplotscolorbardrawstandalone[ 
              colormap name=orangemap,
              colorbar horizontal,
              point meta min=($min_flow),
              point meta max=($max_flow),
              colorbar style={width=10cm,xtick={18,20,25,...,45}}
              ]
              \\end{scope}\n"""
    
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



######################################################################################################
######################################################################################################


function save_graph_tikz_circ(g::Graph, filename::AbstractString; bidirectional=true, standalone_doc=true)
    
    n = num_nodes(g)
    m = num_edges(g)
    
    #Bad choice since it doesn't really matter and makes code clunkier and more restrictive to edge numbering
    #Stride in edges if all edges are both-ways (should be better to sort out transparencies...)
    if bidirectional
        edge_index_step = 2
    else
        edge_index_step = 1
    end

    #Begin tikz picture
    str *= "\\begin{tikzpicture}\n"
    #Add node scope to tikz script
    str *= "\\begin{scope}\n\\tikzstyle{every node}=[draw,circle,fill=black,minimum size=3pt]\n"
    for i in 1:n
        x, y = g.nodes[i].pos
        str *= "\\node ($i) at ($(x*5.0),$(y*5.0)) {};\n"
    end
    str *= "\\end{scope}\n"
    #Add edge scope (if there are edges that is...)
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
    str*="\\end{tikzpicture}"
    
    #To output a minimal latex file.
    if standalone_doc
        head = """
                    \\documentclass{minimal}
                    \\usepackage{tikz}
                    \\begin{document}
               """
        tail = "\n\\end{document}"
        str = head *str* tail
    end
    
    #Write latex plaintext file (does unicode work?)
    open(filename, "w") do f
        write(f, str)
    end
end
