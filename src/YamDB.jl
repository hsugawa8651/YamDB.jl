# SPDX-License-Identifier: MIT
# Based on yamdb (Copyright 2018-2023 Tom Weier)
# Julia port Copyright (C) 2026 Hiroharu Sugawara

module YamDB

using YAML

# --- Type hierarchy ---
abstract type AbstractProperties end

# --- Generic equation patterns ---
module EquationPatterns
    include("equations/patterns.jl")
end

# --- Equation function modules (paper-name wrappers) ---
module Equations
    using ..EquationPatterns
    module Density
        using ...EquationPatterns
        include("equations/density.jl")
    end
    module DynamicViscosity
        using ...EquationPatterns
        include("equations/dynamic_viscosity.jl")
    end
    module Resistivity
        using ...EquationPatterns
        include("equations/resistivity.jl")
    end
    module SurfaceTension
        using ...EquationPatterns
        include("equations/surface_tension.jl")
    end
    module HeatCapacity
        using ...EquationPatterns
        include("equations/heat_capacity.jl")
    end
    module VapourPressure
        using ...EquationPatterns
        include("equations/vapour_pressure.jl")
    end
    module ThermalConductivity
        using ...EquationPatterns
        include("equations/thermal_conductivity.jl")
    end
    module ExpansionCoefficient
        using ...EquationPatterns
        include("equations/expansion_coefficient.jl")
    end
    module SoundVelocity
        using ...EquationPatterns
        include("equations/sound_velocity.jl")
    end
    module VolumeChangeFusion
        using ...EquationPatterns
        include("equations/volume_change_fusion.jl")
    end
end

# Data directory
const DATA_DIR = joinpath(@__DIR__, "..", "data")

# --- Database and Properties ---
include("database.jl")
include("properties.jl")
include("references.jl")

# --- Public API ---
export get_from_metals, get_from_salts, get_from_alloys, get_from_Janz1992
export get_properties_from_db
export Properties, MixtureProperties, SubstanceDB
export density, dynamic_viscosity, expansion_coefficient, heat_capacity
export resistivity, sound_velocity, surface_tension, thermal_conductivity
export vapour_pressure, volume_change_fusion
export source_list, default_source, property_list, equation_limits
export get_comment, get_reference
export get_substance, has_substance, has_component, list_substances
export get_compositions_with_property, get_compositions_with_property_source
export get_from_references, get_references_from_db, load_yaml_references

end # module YamDB
