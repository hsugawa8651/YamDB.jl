# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hiroharu Sugawara
# Part of YamDB.jl

# Basic usage examples for YamDB.jl

using YamDB

# --- Liquid metals ---

na = get_from_metals("Na")

# Constant properties
println("Na melting point: $(na.Tm) K")
println("Na boiling point: $(na.Tb) K")
println("Na molar mass: $(na.M) kg/mol")

# Temperature-dependent properties (default source)
T = 500.0
println("\nNa at $T K (default source):")
println("  density:              $(density(na, T)) kg/m³")
println("  dynamic_viscosity:    $(dynamic_viscosity(na, T)) Pa·s")
println("  thermal_conductivity: $(thermal_conductivity(na, T)) W/(m·K)")
println("  heat_capacity:        $(heat_capacity(na, T)) J/(kg·K)")

# Specific source
println("\nNa density at $T K (Sobolev2011): $(density(na, T; source="Sobolev2011")) kg/m³")

# Available sources
println("\nSources for Na density: $(source_list(na, "density"))")
println("Default source: $(default_source(na, "density"))")

# Temperature range
Tmin, Tmax = equation_limits(na, "density", "Sobolev2011")
println("Sobolev2011 valid range: $Tmin - $Tmax K")

# Volume change on fusion (no temperature argument)
println("\nNa volume change on fusion: $(volume_change_fusion(na)) %")

# --- Molten salts ---

nacl = get_from_salts("NaCl")
println("\n--- NaCl ---")
println("NaCl density at 1100 K: $(density(nacl, 1100.0)) kg/m³")

# --- Salt mixtures ---

cacl2_nacl = get_from_salts("CaCl2-NaCl")
println("\n--- CaCl2-NaCl mixture ---")
comps = get_compositions_with_property(cacl2_nacl, "density")
println("Available compositions: $comps")

# Access a specific composition
comp_key = first(comps)
props_comp = cacl2_nacl.composition[comp_key]
println("$comp_key density at 1100 K: $(density(props_comp, 1100.0)) kg/m³")

# --- Alloys ---

lipb = get_from_alloys("Li-Pb")
println("\n--- Li-Pb alloy ---")
comps = get_compositions_with_property(lipb, "density")
println("Available compositions: $comps")

# --- Janz 1992 database ---

agcl = get_from_Janz1992("AgCl")
println("\n--- AgCl (Janz 1992) ---")
println("AgCl density at 800 K: $(density(agcl, 800.0)) kg/m³")

# --- References ---

ref = get_from_references("Sobolev2011")
println("\n--- Reference ---")
println("Sobolev2011: $ref")
