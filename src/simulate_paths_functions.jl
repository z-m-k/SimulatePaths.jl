
function structural_breaks(T, levels, proportions)
    proportions=1.0.*proportions./sum(proportions)
    sizes=round.(Int,T.*proportions)
    sizes[end]+=T-sum(sizes)
    vcat([
        fill(levels[i],sizes[i])
        for i=1:length(levels)
    ]...)
end
function sinusoid(T, amplitude, cycles)
    (amplitude*sin.(0:cycles*2π/T:cycles*2π))[1:T]
end
function dampen(series, modifier::Array)
    series.*modifier
end
function dampen(series, modifier::Number)
    modifier=collect(1:-(1-modifier)/length(series):modifier)[1:end-1]
    series.*modifier
end
function to_step(series, resolution)
    T=length(series)
    step_length=round(Int,resolution*T)
    out=vcat([
            fill(series[i],step_length)
            for i in round.(Int,collect(1:step_length:T))
            ]...)
    l_diff=length(out)-length(series)
    if l_diff<0
        return [out;fill(out[end],-l_diff)]
    end
    out[1:length(series)]
end
function match_mean(series, target::Number)
    t=mean(series)
    d=t-target
    series .- d
end
function match_mean(series, target::AbstractArray)
    t=mean(target)
    match_mean(series, t)
end
function match_std(series, target::AbstractArray)
    t=std(target)
    match_std(series, t)
end
function match_std(series, target::Number)
    t=std(series)
    m=mean(series)
    d=target/t
    (series .- m) .* d .+ m
end
function ARp(T, ϕs, σ; burn_in=1000, unconditional_mean=false, return_innovations=false)
    ε=randn(T+burn_in).*σ
    munc=ϕs[1]/(1-sum(ϕs[2:end]))
    mcon=ϕs[1]
    if unconditional_mean==true
        munc=ϕs[1]
        mcon=ϕs[1]*(1-sum(ϕs[2:end]))
    end
    y=similar(ε)
    y[1:length(ϕs)-1].=munc
    p=length(ϕs)-1
    for i=1+p:burn_in+T
        y[i]=mcon + y[i-p:i-1]' * reverse(ϕs[2:end]) + ε[i]
    end
    if return_innovations==true
        return y[end-T+1:end], ε[end-T+1:end]
    end
    y[end-T+1:end]
end
function ARp(T, ϕ::Number, σ; kwargs...)
    ARp(T, [0.; ϕ], σ; kwargs...)
end
function ARMApq(T, ϕs, θs, σ; burn_in=1000, unconditional_mean=false, return_innovations=false)
    ε=randn(T+burn_in).*σ
    munc=ϕs[1]/(1-sum(ϕs[2:end]))
    mcon=ϕs[1]
    if unconditional_mean==true
        munc=ϕs[1]
        mcon=ϕs[1]*(1-sum(ϕs[2:end]))
    end
    y=similar(ε)
    p=length(ϕs)-1
    q=length(θs)
    y[1:maximum((p,q))].=munc
    for i=1+maximum((p,q)):burn_in+T
        y[i]=mcon + y[i-p:i-1]' * reverse(ϕs[2:end]) + ε[i-q:i-1]'*reverse(θs) + ε[i]
    end
    if return_innovations==true
        return y[end-T+1:end], ε[end-T+1:end]
    end
    y[end-T+1:end]
end
# Random.seed!(20200412);
# ARMApq(T,[0.;0.99],[0.2;0.3],0.5)