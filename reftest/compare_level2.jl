# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hiroharu Sugawara
# Part of YamDB.jl
#
# Level 2 reftest: compare Julia Properties API against Python reference data.
# Tests all substances x all properties x all sources.
#
# Usage:
#   julia --project=. reftest/compare_level2.jl [db_name]
#   julia --project=. reftest/compare_level2.jl metals

using JSON3
using YamDB

const REFTEST_DIR = joinpath(@__DIR__, "data")

# Tolerance: rtol for floating-point comparison
const RTOL = 1e-12

function reldiff(a::Float64, b::Float64)
    a == b && return 0.0
    return abs(a - b) / max(abs(a), abs(b), 1e-300)
end

const PROPERTY_FUNCS = Dict{String,Function}(
    "density" => YamDB.density,
    "dynamic_viscosity" => YamDB.dynamic_viscosity,
    "expansion_coefficient" => YamDB.expansion_coefficient,
    "heat_capacity" => YamDB.heat_capacity,
    "resistivity" => YamDB.resistivity,
    "sound_velocity" => YamDB.sound_velocity,
    "surface_tension" => YamDB.surface_tension,
    "thermal_conductivity" => YamDB.thermal_conductivity,
    "vapour_pressure" => YamDB.vapour_pressure,
)

const GETTER_FUNCS = Dict{String,Function}(
    "metals" => get_from_metals,
    "salts" => get_from_salts,
    "alloys" => get_from_alloys,
    "Janz1992" => get_from_Janz1992,
)

function compare_results(props::Properties, results, label::String)
    n_pass = 0
    n_fail = 0
    n_error = 0

    for r in results
        prop = String(r["property"])
        source = String(r["source"])
        expected = Float64(r["value"])

        try
            if prop == "volume_change_fusion"
                actual = Float64(YamDB.volume_change_fusion(props; source=source))
            elseif haskey(r, "conc")
                T = Float64(r["T"])
                conc = Float64(r["conc"])
                actual = Float64(PROPERTY_FUNCS[prop](props, T, conc; source=source))
            else
                T = Float64(r["T"])
                actual = Float64(PROPERTY_FUNCS[prop](props, T; source=source))
            end

            rd = reldiff(actual, expected)
            if rd <= RTOL
                n_pass += 1
            else
                T_str = haskey(r, "T") ? "T=$(r["T"])" : ""
                conc_str = haskey(r, "conc") ? ",x=$(r["conc"])" : ""
                println("  FAIL: $label $prop/$source($T_str$conc_str) = $actual, " *
                        "expected $expected (reldiff=$rd)")
                n_fail += 1
            end
        catch e
            T_str = haskey(r, "T") ? "T=$(r["T"])" : ""
            println("  ERROR: $label $prop/$source($T_str): $e")
            n_error += 1
        end
    end

    return n_pass, n_fail, n_error
end

function compare_db(db_name::String)
    reffile = joinpath(REFTEST_DIR, "level2_$(db_name).json")
    if !isfile(reffile)
        println("SKIP: $reffile not found")
        return 0, 0, 0
    end

    getter = GETTER_FUNCS[db_name]
    data = JSON3.read(read(reffile, String))

    total_pass = 0
    total_fail = 0
    total_error = 0

    for (substance_name, entry) in pairs(data)
        name = String(substance_name)
        obj = getter(name)
        entry_type = String(entry["type"])

        if entry_type == "pure"
            results = entry["results"]
            p, f, e = compare_results(obj, results, name)
            total_pass += p
            total_fail += f
            total_error += e

        elseif entry_type == "mixture"
            # Specific compositions
            if haskey(entry, "compositions")
                for (comp_key, comp_results) in pairs(entry["compositions"])
                    ck = String(comp_key)
                    comp_props = obj.composition[ck]
                    p, f, e = compare_results(comp_props, comp_results, "$name/$ck")
                    total_pass += p
                    total_fail += f
                    total_error += e
                end
            end

            # Range composition
            if haskey(entry, "range_results")
                range_props = obj.composition["range"]
                p, f, e = compare_results(range_props, entry["range_results"], "$name/range")
                total_pass += p
                total_fail += f
                total_error += e
            end
        end
    end

    return total_pass, total_fail, total_error
end

function main()
    dbs = length(ARGS) > 0 ? ARGS : ["metals", "salts", "alloys", "Janz1992"]
    total_pass = 0
    total_fail = 0
    total_error = 0

    for db_name in dbs
        println("=== $db_name ===")
        p, f, e = compare_db(db_name)
        println("  PASS=$p  FAIL=$f  ERROR=$e")
        total_pass += p
        total_fail += f
        total_error += e
    end

    println("\n=== TOTAL ===")
    println("  PASS=$total_pass  FAIL=$total_fail  ERROR=$total_error")

    if total_fail > 0 || total_error > 0
        println("\nLevel 2 reftest FAILED")
        exit(1)
    else
        println("\nLevel 2 reftest PASSED")
    end
end

main()
