#plot distributions of the road lengths of the generated cities

using TrafficNetworks, SkeletonCities, DataFrames, Gadfly, Distributions

# top_dir = "/space/ae13414/Data/beta-skeletons"
# cd(top_dir)

dirs = readdir()

alphas = Float64[]
thetas = Float64[]
betas = Float64[]

for dir in dirs

    beta = parse(Float64, split(dir, '_')[2])

    println("In dir for β=$(beta)\n")

    lengths = Float64[]

    cd(dir)

        files = readdir()
        filter!(x -> contains(x, "json"), files)

        for file in files
            g = load_graph(file)
            edge_lengths = [norm(e.target.pos - e.source.pos) for e in g.edges]
            lengths = [lengths; edge_lengths]
        end
    cd("..")

    d = fit(Gamma, lengths)

    println("Dist: α = $(d.α)\tθ = $(d.θ)\n\n")

    push!(alphas, d.α)
    push!(thetas, d.θ)
    push!(betas, beta)

    x = lengths
    max_x = round(maximum(x), 2)
    xx = collect(0:0.01:max_x)

    p = plot(layer(x=x, Geom.density, Theme(default_color=colorant"deepskyblue")),
             layer(x=xx, y=pdf(Gamma(d.α, d.θ), xx), Geom.line, default_color=colorant"green")),
             Guide.title("Road length distribution: β=$(beta)"),
             Guide.xlabel("Road-segment length"),
             Guide.ylabel("Density"),
             Guide.manual_color_key("", ["β-skeleton","Γ-dist (α=$(d.α), θ=$(d.θ))"], ["deepskyblue", "green"]))

    draw(PDF("density_beta_$(beta).pdf", 10cm, 10cm), p)
end

p2 = plot(layer(x=betas, y=alphas, Geom.point, Theme(default_color=colorant"orange")),
            layer(x=betas, y=thetas, Geom.point, Theme(default_color=colorant"green")),
            Guide.title("Fitting parameters: Gamma distribution"),
            Guide.xlabel("β"),
            Guide.ylabel("Dist. Parameter"),
            Guide.manual_color_key("", ["α","θ"], ["orange","green"]))

draw(PDF("fit_params_skeletons_gammadist.pdf", 10cm, 10cm), p2)