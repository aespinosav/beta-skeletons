#Script that draws distributions of "street lenghts" for cities from Bar-Gera's repository
using TrafficNetworks, SkeletonCities, Gadfly, DataFrames

cd("/space/ae13414/phd/test_data/samples")
files = readdir()
split_strings = map(x -> split(x, '_'), files)

for i in 1:length(files)

    city_name =split_strings[i][1]
    title = "Road length distribution for $(city_name)"
    xlabel = "Road-segment length"

    dat = load_tntp_to_dataframe(files[i])

    println("\nLoaded $(city_name)\n")

    rsl = dat[5] #road segment lengths

    println("Got fftt for $(city_name)\nNow Plotting...\t")

    p = plot(x=rsl, Geom.density,
            Guide.xlabel(xlabel),
            Guide.title(title))

    print("Done!\n\n")

    name_for_plot = city_name*".pdf"
    draw(PDF(name_for_plot, 10cm, 10cm), p)
end