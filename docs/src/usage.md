# [Usage Guide](@id usage-guide)

## Loading Substances

YamDB.jl provides four database access functions:

```julia
using YamDB

# Liquid metals (36 substances)
na = get_from_metals("Na")

# Molten salts (151 substances)
nacl = get_from_salts("NaCl")

# Alloys (6 systems)
lipb = get_from_alloys("Li-Pb")

# Janz 1992 NIST database (1,022 substances)
nacl_j = get_from_Janz1992("NaCl")

# Custom YAML database file
props = get_properties_from_db("/path/to/custom.yml", "MySubstance")
```

Pure substances return a [`Properties`](@ref) object.
Mixtures (names containing `-`) return a [`MixtureProperties`](@ref) object.

## Computing Properties

All temperature-dependent properties take a `Properties` object and temperature in Kelvin:

```julia
na = get_from_metals("Na")

density(na, 500.0)                 # Default source
density(na, 500.0; source="Sobolev2011")  # Specific source
dynamic_viscosity(na, 500.0)
heat_capacity(na, 500.0)
```

Volume change on fusion has no temperature argument:

```julia
volume_change_fusion(na)
volume_change_fusion(na; source="Bockrisetal1962")
```

## Querying Metadata

```julia
# Available properties
property_list(na)

# Sources for a property
source_list(na, "density")

# Default source
default_source(na, "density")

# Temperature limits
equation_limits(na, "density", "Sobolev2011")  # (Tmin, Tmax)

# Concentration limits
equation_limits(na, "density", "SomeSource"; variable="x")  # (xmin, xmax)

# Comment and reference
get_comment(na, "density", "Sobolev2011")
get_reference(na, "density", "Sobolev2011")
```

## Constant Properties

Melting temperature, boiling temperature, and molar mass are stored as fields:

```julia
na.Tm  # 370.87 K
na.Tb  # 1156.15 K
na.M   # 0.02299 kg/mol
```

## Salt Mixtures

Mixtures have a `composition` dictionary with a `Properties` object per composition:

```julia
mix = get_from_salts("CaCl2-NaCl")

# List compositions with density data
get_compositions_with_property(mix, "density")
# ["0-100", "15-85", ..., "100-0"]

# Include "range" composition
get_compositions_with_property(mix, "density"; keep_range=true)

# Access a specific composition
props_50 = mix.composition["50.9-49.1"]
density(props_50, 1100.0)

# Concentration-dependent (range) composition
# x = mol% of first component
range_props = mix.composition["range"]
density(range_props, 1100.0, 30.0)
```

## Literature References

```julia
# Look up by citation key
get_from_references("IidaGuthrie1988")
# "Iida, T., Guthrie, R.I.L., 1988. ..."

# From a custom references file
get_references_from_db("/path/to/references.yml", "SomeKey")
```
