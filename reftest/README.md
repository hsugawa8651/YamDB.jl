# Reference Testing (Reftest)

Reference tests compare YamDB.jl results against the Python yamdb implementation to verify numerical equivalence.

## Prerequisites

Install Python yamdb:
```bash
pip install yamdb
```

## Levels

### Level 0 — Individual Equation Functions

Compares each equation function (e.g., `Sobolev2011`, `IAEA2008`) with known coefficients against Python reference values.

- **Tolerance**: MAX_ULP = 32 (see below)
- **Data points**: 541

```bash
# Generate Python reference data
python3 reftest/generate_level0.py

# Run Julia comparison (all modules)
julia --project=. reftest/compare_level0.jl

# Single module
julia --project=. reftest/compare_level0.jl density
julia --project=. reftest/compare_level0.jl vapour_pressure
```

### Level 2 — Full Database

Compares all substances across all four databases (metals, salts, alloys, Janz1992) for all properties and all sources at multiple temperatures.

- **Tolerance**: rtol = 1e-12
- **Data points**: 86,294

```bash
# Generate Python reference data
python3 reftest/generate_level2.py

# Run Julia comparison (all databases)
julia --project=. reftest/compare_level2.jl

# Single database
julia --project=. reftest/compare_level2.jl metals
julia --project=. reftest/compare_level2.jl salts
julia --project=. reftest/compare_level2.jl Janz1992
```

## ULP Tolerance (Level 0)

Level 0 uses ULP (Unit in the Last Place) comparison with a maximum allowed difference of 32.

This tolerance is needed because Python's `np.power(x, n)` uses the C library `pow()` function, while Julia's `x^n` with integer `n` uses repeated multiplication. These produce slightly different floating-point results.

The worst case is `Wangetal2021` in vapour_pressure at T=800 K (31 ULP, reldiff < 5e-15).

## Reference Data

Reference data files are stored in `reftest/data/` and are **not** committed to the repository (listed in `.gitignore`). To regenerate:

1. Install Python yamdb
2. Run the generator scripts from the YamDB.jl root directory
3. Run the Julia comparison scripts

### Generated files

| File pattern | Level | Content |
|---|---|---|
| `level0_*.json` | 0 | Per-module equation function results |
| `level2_*.json` | 2 | Per-database substance results |
