# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hiroharu Sugawara
# Part of YamDB.jl
#
# Level 0 reftest: compare Julia equation functions against Python reference data.
# Goal: agreement within 1 ULP (C pow() implementation differences may cause
# 1-bit differences for np.power(x, n) vs Julia x^n).
#
# Usage:
#   julia --project=. reftest/compare_level0.jl [module_name]
#   julia --project=. reftest/compare_level0.jl density

using JSON3
using YamDB

const REFTEST_DIR = joinpath(@__DIR__, "data")

# Maximum allowed ULP difference.
# C pow() implementations differ between Python (numpy) and Julia (libm).
# np.power(x, n) uses libm pow() while Julia x^n uses repeated multiplication.
# Single-term differences are typically 1-2 ULP, but accumulation across
# polynomial terms with large intermediate values can reach ~32 ULP
# (e.g. Wangetal2021 with (T-273.15)^3 at T=800).
# reldiff remains < 5e-15 in all cases.
const MAX_ULP = 32

#=
    ulp_distance(a, b) -> Int

Count the number of ULPs between two Float64 values.
=#
function ulp_distance(a::Float64, b::Float64)
    a == b && return 0
    (isnan(a) || isnan(b)) && return typemax(Int)
    (isinf(a) || isinf(b)) && return typemax(Int)
    ia = reinterpret(Int64, a)
    ib = reinterpret(Int64, b)
    # Handle sign difference
    if ia < 0
        ia = typemin(Int64) - ia
    end
    if ib < 0
        ib = typemin(Int64) - ib
    end
    return abs(ia - ib)
end

# Module name -> Julia submodule mapping
const MODULE_MAP = Dict{String,Module}(
    "density" => YamDB.Equations.Density,
    "dynamic_viscosity" => YamDB.Equations.DynamicViscosity,
    "resistivity" => YamDB.Equations.Resistivity,
    "surface_tension" => YamDB.Equations.SurfaceTension,
    "heat_capacity" => YamDB.Equations.HeatCapacity,
    "vapour_pressure" => YamDB.Equations.VapourPressure,
    "thermal_conductivity" => YamDB.Equations.ThermalConductivity,
    "expansion_coefficient" => YamDB.Equations.ExpansionCoefficient,
    "sound_velocity" => YamDB.Equations.SoundVelocity,
    "volume_change_fusion" => YamDB.Equations.VolumeChangeFusion,
)

function compare_module(module_name::String)
    reffile = joinpath(REFTEST_DIR, "level0_$(module_name).json")
    if !isfile(reffile)
        println("SKIP: $reffile not found")
        return 0, 0, 0
    end

    data = JSON3.read(read(reffile, String))
    n_pass = 0
    n_fail = 0
    n_skip = 0
    mod = MODULE_MAP[module_name]

    for case in data
        func_name = Symbol(case["function"])
        if !isdefined(mod, func_name)
            println("  SKIP: $func_name not implemented")
            n_skip += 1
            continue
        end
        func = getfield(mod, func_name)
        coef = Dict{String,Any}(String(k) => v for (k, v) in pairs(case["coef"]))

        # Convert JSON arrays/objects to native Julia types
        for (k, v) in coef
            if v isa JSON3.Array
                # Check if array of objects (e.g. Ohse1985 range segments)
                if length(v) > 0 && first(v) isa JSON3.Object
                    coef[k] = [Dict{String,Any}(String(kk) => vv for (kk, vv) in pairs(obj)) for obj in v]
                else
                    coef[k] = collect(Float64, v)
                end
            end
        end

        for result in case["results"]
            expected = Float64(result["value"])

            if haskey(result, "T")
                T = Float64(result["T"])
                if haskey(result, "conc")
                    conc = Float64(result["conc"])
                    actual = func(T, conc; coef=coef)
                else
                    actual = func(T; coef=coef)
                end
                label = "$func_name(T=$T)"
            else
                # No temperature dependence (e.g. volume_change_fusion)
                actual = func(; coef=coef)
                label = "$func_name()"
            end

            ulps = ulp_distance(Float64(actual), expected)
            if ulps <= MAX_ULP
                n_pass += 1
                if ulps > 0
                    println("  WARN: $label off by $ulps ULP (accepted)")
                end
            else
                reldiff = abs(actual - expected) / max(abs(expected), 1e-300)
                println("  FAIL: $label = $actual, expected $expected " *
                        "(ulps=$ulps, reldiff=$reldiff)")
                n_fail += 1
            end
        end
    end

    return n_pass, n_fail, n_skip
end

function main()
    modules = length(ARGS) > 0 ? ARGS : collect(keys(MODULE_MAP))
    total_pass = 0
    total_fail = 0
    total_skip = 0

    for mod_name in sort(modules)
        println("=== $mod_name ===")
        p, f, s = compare_module(mod_name)
        println("  PASS=$p  FAIL=$f  SKIP=$s")
        total_pass += p
        total_fail += f
        total_skip += s
    end

    println("\n=== TOTAL ===")
    println("  PASS=$total_pass  FAIL=$total_fail  SKIP=$total_skip")

    if total_fail > 0
        println("\nLevel 0 reftest FAILED")
        exit(1)
    else
        println("\nLevel 0 reftest PASSED")
    end
end

main()
