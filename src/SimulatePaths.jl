# plot(x=1:T, y=dampen(sinusoid(T, 2.0, 3.0), 0.2), Geom.line)
# plot(x=1:T, y=dampen(sinusoid(T, 2.0, 3.0), 1.5.+sinusoid(T, 1.0, 2.0)), Geom.line)
# plot(x=1:T, y=to_step(dampen(sinusoid(T, 2.0, 3.0), 1.5.+sinusoid(T, 1.0, 2.0)),0.02), Geom.line)
# plot(x=1:T, y=match_mean(to_step(dampen(sinusoid(T, 2.0, 3.0), 1.5.+sinusoid(T, 1.0, 2.0)),0.02), 0.5), Geom.line)
# plot(x=1:T, y=match_std(match_mean(to_step(dampen(sinusoid(T, 2.0, 3.0), 1.5.+sinusoid(T, 1.0, 2.0)),0.02), 0.5), 0.5), Geom.line)
# plot(x=1:T, y=ARp(T, [0.5;0.98], 0.25; unconditional_mean=true), Geom.line)
# plot(x=1:T, y=to_step(ARp(T, [0.5;0.98], 0.25; unconditional_mean=true),0.01), Geom.line)
module SimulatePaths

    using LinearAlgebra
    using Statistics: mean, std
    using Gadfly, DataFrames

    export structural_breaks
    export sinusoid
    export dampen
    export to_step
    export match_mean
    export match_std
    export ARp
    export ARMApq
    export paths_to_df
    export plot_paths

    include("simulate_paths_functions.jl")
    include("plot_paths_functions.jl")
end # module
