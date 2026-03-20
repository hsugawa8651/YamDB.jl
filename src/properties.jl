# SPDX-License-Identifier: MIT
# Based on yamdb (Copyright 2018-2023 Tom Weier)
# Julia port Copyright (C) 2026 Hiroharu Sugawara

# --- Module mapping: property name -> equation submodule ---

const MODULE_MAP = Dict{String,Module}(
    "density" => Equations.Density,
    "dynamic_viscosity" => Equations.DynamicViscosity,
    "expansion_coefficient" => Equations.ExpansionCoefficient,
    "heat_capacity" => Equations.HeatCapacity,
    "resistivity" => Equations.Resistivity,
    "sound_velocity" => Equations.SoundVelocity,
    "surface_tension" => Equations.SurfaceTension,
    "thermal_conductivity" => Equations.ThermalConductivity,
    "vapour_pressure" => Equations.VapourPressure,
    "volume_change_fusion" => Equations.VolumeChangeFusion,
)

const CONSTANT_PROPERTIES = ("Tm", "Tb", "M")

# --- Properties ---

"""
    Properties

Thermophysical properties object for a single substance or composition.
Created by [`get_from_metals`](@ref), [`get_from_salts`](@ref), etc.

# Fields
- `Tm::Union{Float64,Nothing}`: Melting temperature (K)
- `Tb::Union{Float64,Nothing}`: Boiling temperature (K)
- `M::Union{Float64,Nothing}`: Molar mass (kg/mol)
"""
struct Properties <: AbstractProperties
    substance::Dict{String,Any}
    Tm::Union{Float64,Nothing}
    Tb::Union{Float64,Nothing}
    M::Union{Float64,Nothing}
    _func_dicts::Dict{String,Dict{String,Function}}
end

function Properties(substance::Dict{String,Any})
    isempty(substance) && throw(ArgumentError("Empty substance dictionary"))

    Tm = _get_constant(substance, "Tm")
    Tb = _get_constant(substance, "Tb")
    M = _get_constant(substance, "M")

    func_dicts = Dict{String,Dict{String,Function}}()
    for (prop, mod) in MODULE_MAP
        if haskey(substance, prop)
            func_dicts[prop] = _create_func_dict(substance, prop, mod, Tm, Tb, M)
        end
    end

    return Properties(substance, Tm, Tb, M, func_dicts)
end

function Properties(::Nothing)
    throw(ArgumentError("No such substance"))
end

function _get_constant(substance::Dict{String,Any}, key::String)
    v = get(substance, key, nothing)
    return isnothing(v) ? nothing : Float64(v)
end

function _create_func_dict(
    substance::Dict{String,Any},
    prop::String,
    mod::Module,
    Tm, Tb, M,
)
    prop_data = substance[prop]
    dict = Dict{String,Function}()
    for (source_name, source_data) in prop_data
        eq_name = source_data["equation"]
        func = getfield(mod, Symbol(eq_name))
        # Build coefficient dict: source_data + constant properties
        coef = Dict{String,Any}(String(k) => v for (k, v) in source_data)
        # Inject constant properties (don't overwrite existing keys)
        for (cp, val) in (("Tm", Tm), ("Tb", Tb), ("M", M))
            if !haskey(coef, cp) && !isnothing(val)
                coef[cp] = val
            end
        end
        # Convert YAML list values (Vector{Any}) to Vector{Float64} where possible
        for (k, v) in coef
            if v isa Vector && all(x -> x isa Number, v)
                coef[k] = Float64.(v)
            end
        end
        # Create closure binding coef to func
        if prop == "volume_change_fusion"
            dict[source_name] = () -> func(; coef=coef)
        else
            dict[source_name] = (args...) -> func(args...; coef=coef)
        end
    end
    return dict
end

# --- Property accessors ---

#=
    _call_property(p, prop, args...; source) -> Float64

Dispatch a property call to the appropriate equation function.
=#
function _call_property(p::Properties, prop::String, args...; source=nothing)
    if !haskey(p._func_dicts, prop)
        error("Property '$prop' not available for this substance")
    end
    if isnothing(source)
        source = default_source(p, prop)
    end
    if isnothing(source)
        error("No default source for property '$prop'; specify source explicitly")
    end
    return p._func_dicts[prop][source](args...)
end

# Temperature-dependent properties
const _PROP_DOCS = Dict{Symbol,Tuple{String,String}}(
    :density => ("density", "kg/m³"),
    :dynamic_viscosity => ("dynamic viscosity", "Pa·s"),
    :expansion_coefficient => ("volumetric expansion coefficient", "1/K"),
    :heat_capacity => ("heat capacity", "J/(kg·K)"),
    :resistivity => ("electrical resistivity", "Ω·m"),
    :sound_velocity => ("sound velocity", "m/s"),
    :surface_tension => ("surface tension", "N/m"),
    :thermal_conductivity => ("thermal conductivity", "W/(m·K)"),
    :vapour_pressure => ("vapour pressure", "Pa"),
)

for prop in (
    :density, :dynamic_viscosity, :expansion_coefficient, :heat_capacity,
    :resistivity, :sound_velocity, :surface_tension, :thermal_conductivity,
    :vapour_pressure,
)
    prop_str = String(prop)
    desc, unit = _PROP_DOCS[prop]
    docstr = """
        $prop(p::Properties, T::Real, args...; source=nothing)

    Compute the $desc at temperature `T` (K). Returns value in $unit.
    If `source` is not specified, the default source is used.
    For concentration-dependent properties, pass concentration as additional argument.
    """
    @eval begin
        @doc $docstr
        function $prop(p::Properties, T::Real, args...; source=nothing)
            return _call_property(p, $prop_str, Float64(T), args...; source=source)
        end
    end
end

"""
    volume_change_fusion(p::Properties; source=nothing)

Return the volume change on fusion as a percentage value.
If `source` is not specified, the default source is used.
"""
function volume_change_fusion(p::Properties; source=nothing)
    return _call_property(p, "volume_change_fusion"; source=source)
end

# --- Query methods ---

"""
    source_list(p::Properties, prop::String) -> Vector{String}

Return a list of available sources for the given property.
"""
function source_list(p::Properties, prop::String)
    if !haskey(p.substance, prop)
        error("Property '$prop' not available")
    end
    return collect(keys(p.substance[prop]))
end

"""
    default_source(p::Properties, prop::String) -> Union{String, Nothing}

Return the default source for a property, or `nothing` if none is defined.
"""
function default_source(p::Properties, prop::String)
    if !haskey(p.substance, prop)
        return nothing
    end
    for (source, data) in p.substance[prop]
        if haskey(data, "default")
            return source
        end
    end
    return nothing
end

"""
    property_list(p::Properties) -> Vector{String}

Return a list of all available properties for the substance.
"""
function property_list(p::Properties)
    return collect(keys(p._func_dicts))
end

"""
    equation_limits(p::Properties, prop, source; variable="T") -> Tuple

Return the valid range for a property equation. By default returns `(Tmin, Tmax)`.
Set `variable="x"` to get concentration limits `(xmin, xmax)`.
Values are `nothing` if not specified in the database.
"""
function equation_limits(p::Properties, prop::String, source::String; variable="T")
    data = p.substance[prop][source]
    if variable == "T"
        tmin = get(data, "Tmin", nothing)
        tmax = get(data, "Tmax", nothing)
        return (tmin, tmax)
    elseif variable == "x"
        xmin = get(data, "xmin", nothing)
        xmax = get(data, "xmax", nothing)
        return (xmin, xmax)
    else
        return nothing
    end
end

"""
    get_comment(p::Properties, prop, source) -> Union{String, Nothing}

Return the comment for a property source, or `nothing` if none exists.
"""
function get_comment(p::Properties, prop::String, source::String)
    data = get(p.substance[prop], source, nothing)
    isnothing(data) && return nothing
    return get(data, "comment", nothing)
end

"""
    get_reference(p::Properties, prop, source) -> String

Return the reference key for a property source. Falls back to `source` if no explicit reference is defined.
"""
function get_reference(p::Properties, prop::String, source::String)
    data = p.substance[prop][source]
    return get(data, "reference", source)
end

# --- MixtureProperties ---

"""
    MixtureProperties

Properties object for a multi-component mixture (e.g., salt mixtures, alloys).
Contains a `composition` dictionary mapping composition keys (e.g., `"0-100"`, `"range"`)
to [`Properties`](@ref) objects.
"""
struct MixtureProperties <: AbstractProperties
    substance::Dict{String,Any}
    composition::Dict{String,Properties}
end

function MixtureProperties(substance::Dict{String,Any})
    isempty(substance) && throw(ArgumentError("Empty substance dictionary"))
    comp = Dict{String,Properties}()
    for (key, val) in substance
        comp[key] = Properties(val)
    end
    return MixtureProperties(substance, comp)
end

function MixtureProperties(::Nothing)
    throw(ArgumentError("No such substance"))
end

function _extract_concentration(key::String)
    idx = findfirst('-', key)
    if !isnothing(idx) && idx > 0
        return parse(Float64, key[1:idx-1])
    end
    return 999.0  # "range" -> end of list
end

"""
    get_compositions_with_property(mp::MixtureProperties, prop; keep_range=false)

Return a sorted list of compositions that have data for the given property.
The `"range"` composition is excluded by default; set `keep_range=true` to include it.
"""
function get_compositions_with_property(
    mp::MixtureProperties, prop::String; keep_range=false,
)
    plist = String[]
    for (comp_key, props) in mp.composition
        if prop in property_list(props)
            push!(plist, comp_key)
        end
    end
    isempty(plist) && return nothing
    sort!(plist; by=_extract_concentration)
    if !keep_range && "range" in plist
        filter!(!isequal("range"), plist)
    end
    return plist
end

"""
    get_compositions_with_property_source(mp::MixtureProperties, prop, source; keep_range=false)

Return a sorted list of compositions that have the given property from the given source.
"""
function get_compositions_with_property_source(
    mp::MixtureProperties, prop::String, source::String; keep_range=false,
)
    plist = String[]
    for (comp_key, props) in mp.composition
        if prop in property_list(props) && source in source_list(props, prop)
            push!(plist, comp_key)
        end
    end
    isempty(plist) && return nothing
    sort!(plist; by=_extract_concentration)
    if !keep_range && "range" in plist
        filter!(!isequal("range"), plist)
    end
    return plist
end

# --- Public API functions ---

"""
    get_properties_from_db(db_file, substance) -> Properties or MixtureProperties

Load a substance from a YAML database file. Returns [`MixtureProperties`](@ref)
if the substance name contains `-`, otherwise [`Properties`](@ref).
"""
function get_properties_from_db(db_file::AbstractString, substance::AbstractString)
    db = _get_cached_db(db_file)
    sub = get_substance(db, substance)
    if isnothing(sub)
        throw(ArgumentError("Substance '$substance' not found in database"))
    end
    if contains(substance, '-')
        return MixtureProperties(sub)
    else
        return Properties(sub)
    end
end

function _get_properties_from_included_db(db_file::AbstractString, substance::AbstractString)
    fname = joinpath(DATA_DIR, db_file)
    return get_properties_from_db(fname, substance)
end

"""
    get_from_metals(substance) -> Properties

Load a liquid metal from the bundled `metals.yml` database (36 substances).
"""
function get_from_metals(substance::AbstractString)
    return _get_properties_from_included_db("metals.yml", substance)
end

"""
    get_from_salts(substance) -> Properties or MixtureProperties

Load a molten salt from the bundled `salts.yml` database (151 substances).
"""
function get_from_salts(substance::AbstractString)
    return _get_properties_from_included_db("salts.yml", substance)
end

"""
    get_from_alloys(substance) -> MixtureProperties

Load an alloy system from the bundled `alloys.yml` database (6 systems).
"""
function get_from_alloys(substance::AbstractString)
    return _get_properties_from_included_db("alloys.yml", substance)
end

"""
    get_from_Janz1992(substance) -> Properties or MixtureProperties

Load a substance from the bundled Janz 1992 NIST database (`Janz1992_ed.yml`, 1,022 substances).
"""
function get_from_Janz1992(substance::AbstractString)
    return _get_properties_from_included_db("Janz1992_ed.yml", substance)
end
