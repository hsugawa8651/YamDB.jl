# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hiroharu Sugawara
# Part of YamDB.jl

# Plot density of Na from multiple sources
# Requires: Plots.jl (`using Pkg; Pkg.add("Plots")`)

using YamDB
using Plots

na = get_from_metals("Na")

sources = source_list(na, "density")

p = plot(;
    xlabel="Temperature (K)",
    ylabel="Density (kg/m³)",
    title="Na Density — Multiple Sources",
    legend=:topright,
)

for src in sources
    Tmin, Tmax = equation_limits(na, "density", src)
    isnothing(Tmin) && continue
    isnothing(Tmax) && continue
    T = range(Tmin, Tmax; length=100)
    rho = [density(na, t; source=src) for t in T]
    plot!(p, T, rho; label=src)
end

display(p)
# savefig(p, "na_density.png")
