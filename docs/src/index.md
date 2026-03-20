# YamDB.jl

Julia port of [yamdb](https://codebase.helmholtz.cloud/prosa/yamdb) — Yet Another Materials Database for thermophysical properties of liquid metals and molten salts.

## Features

- Thermophysical properties of 36 liquid metals, 151 molten salts, 6 alloy systems, and 1,022 Janz 1992 substances
- 10 physical properties: density, dynamic viscosity, expansion coefficient, heat capacity, resistivity, sound velocity, surface tension, thermal conductivity, vapour pressure, volume change on fusion
- Multiple literature sources per property with source selection
- Concentration-dependent properties for salt mixtures and alloys
- Literature reference lookup

## Installation

```julia
using Pkg
Pkg.add(url="https://github.com/hsugawa8651/YamDB.jl")
```

## Quick Example

```julia
using YamDB

na = get_from_metals("Na")
density(na, 500.0)                          # 898.21 kg/m³
density(na, 500.0; source="Sobolev2011")    # 896.5 kg/m³
```

See the [Usage Guide](@ref usage-guide) for more details.

## Citation

If you use YamDB.jl in your research, please cite both:

**YamDB.jl:**
> Sugawara, H. (2026). YamDB.jl: Julia port of yamdb for thermophysical properties of liquid metals and molten salts (Version 0.1.0) [Computer software].

**Original yamdb:**
> Weier, T., Sarma, M. (2023). yamdb — Yet Another (Molten) Materials Database. *Journal of Open Research Software*, 11(1), p.10. [doi:10.5334/jors.493](https://doi.org/10.5334/jors.493)

## License

MIT License.

## Credits

Julia port by Hiroharu Sugawara.

Based on [yamdb](https://codebase.helmholtz.cloud/prosa/yamdb) (Python) v0.3.0 by
- Tom Weier
- Mihails Sarma
