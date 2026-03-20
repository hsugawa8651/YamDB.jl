# YamDB.jl

Julia port of [yamdb](https://codebase.helmholtz.cloud/prosa/yamdb) — Yet Another Materials Database for thermophysical properties of liquid metals and molten salts.

## Overview

YamDB.jl provides thermophysical property data for liquid metals, molten salts, and alloys. Properties are computed from empirical correlations published in the scientific literature, with coefficients stored in YAML data files.

**Included databases:**

| Database | File | Contents |
| -------- | ---- | -------- |
| Metals | `metals.yml` | 36 liquid metals |
| Salts | `salts.yml` | 151 molten salts and mixtures |
| Alloys | `alloys.yml` | 6 alloy systems |
| Janz 1992 | `Janz1992_ed.yml` | 1,022 substances (NIST Molten Salts Database) |

## Installation

```julia
using Pkg
Pkg.add(url="https://github.com/hsugawa8651/YamDB.jl")
```

## Quick Start

```julia
using YamDB

na = get_from_metals("Na")
density(na, 500.0)                          # 898.21 kg/m³
density(na, 500.0; source="Sobolev2011")    # 896.5 kg/m³

nacl = get_from_salts("NaCl")
density(nacl, 1100.0)                       # 1541.80 kg/m³
```

See the [documentation](https://hsugawa8651.github.io/YamDB.jl) for the full API and usage guide.

## Citation

If you use YamDB.jl in your research, please cite both:

**YamDB.jl:**
> Sugawara, H. (2026). YamDB.jl: Julia port of yamdb for thermophysical properties of liquid metals and molten salts (Version 0.1.0) [Computer software].

**Original yamdb:**
> Weier, T., Nash, W., Personnettaz, P., Weber, N. (2025). Yamdb: easily accessible thermophysical properties of liquid metals and molten salts. *Journal of Open Research Software*, 13(1), 16. [doi:10.5334/jors.493](https://doi.org/10.5334/jors.493)

**Data sources:** In addition, please cite the original sources of the data/equations for the material properties you use. References are available in `references.yml` shipped with YamDB.jl. You can look up references programmatically:

```julia
# Get the reference for a specific property source
get_reference(na, "density", "Sobolev2011")

# Look up by citation key
get_from_references("Sobolev2011")
```

## Contributing

Bug reports and feature requests are welcome via [GitHub Issues](https://github.com/hsugawa8651/YamDB.jl/issues).
Before opening a pull request, start an issue or a discussion on the topic.
This project follows the [Julia Community Standards](https://julialang.org/community/standards/).

## License

MIT License. See [LICENSE](LICENSE) for details.

Based on yamdb (Copyright 2018-2023 Tom Weier).
Julia port Copyright (C) 2026 Hiroharu Sugawara.
