function paths_to_df(paths::Array{Float64,2}; names=[], t="", T=[])
    if size(paths,1)<size(paths,2)
        return paths_to_df(Matrix(paths'); names=names, t=t, T=T)
    end
    if length(names)!=size(paths,2)
        names=["path_$i" for i=1:size(paths,2)]
    end
    if length(T)!=size(paths,1)
        T=1:size(paths,1)
    end
    df_true=DataFrame(t=T)
    for i=1:length(names)
        df_true[!,Symbol(names[i])]=paths[:,i]
    end
    df_stacked=stack(df_true)
    df_stacked[!,:type].=t
    return df_stacked
end
function paths_to_df(paths::Array{Array{Float64,2},1}; kwargs...)
    paths_to_df(cat(paths...;dims=3); kwargs...)
end
function paths_to_df(paths::Array{Float64,3}; kwargs...)
    stacked_dfs=[
        paths_to_df(paths[:,:,i]; kwargs...)
        for i=1:size(paths,3)
    ]
    stacked_df=stacked_dfs[1]
    stacked_df[!,:ymin]=stacked_dfs[2][:,:value]
    stacked_df[!,:ymax]=stacked_dfs[3][:,:value]
    stacked_df
end
function plot_paths(args...; names=[], types=[], draw_plots=true)
    df_stacked=[
        begin
            o=[]
            if typeof(args[i])==Array{Float64,2}
                o=paths_to_df([args[i],args[i],args[i]]; names=names, t=types[i])
            else
                o=paths_to_df(args[i]; names=names, t=types[i])
            end
            o
        end
        for i=1:length(args)
    ]
    df_stacked=vcat(df_stacked...)
    path_names=Set(df_stacked[:,:variable])
    if length(names)>0
        path_names=map(Symbol, names)
    end
    p=vstack([
        plot(
            df_stacked[df_stacked[:,:variable].=="$b", :],
            x=:t,
            y=:value, color=:type, Geom.line,
            ymin=:ymin, ymax=:ymax, Geom.ribbon,
            Theme(key_position=:bottom, alphas=[0.35]), Guide.xlabel(""), Guide.ylabel(string(b))
        )
        for b in path_names
    ]...)
    if draw_plots==true
        draw(SVG(30cm,length(path_names)*7.5cm), p)
    else
        return p
    end
end
function plot_paths(path_dict::Dict; kwargs...)
    plot_paths(values(path_dict)...; types=collect(keys(path_dict)), kwargs...)
end