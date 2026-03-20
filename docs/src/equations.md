# [Equation Patterns](@id equation-patterns)

YamDB.jl uses a two-layer equation design:

1. **Equation patterns** — generic mathematical functions (this page)
2. **Paper-name wrappers** — functions named after publications that call a pattern with specific coefficients

All patterns are defined in `src/equations/patterns.jl` and are internal to the package.

## Constant and Linear

| Pattern | Formula |
|---------|---------|
| `constant(val)` | ``val`` |
| `linear(T, a, b)` | ``a + bT`` |
| `linear_tref(T, a, b, T_{ref})` | ``a - b(T - T_{ref})`` |

## Polynomials in T

| Pattern | Formula |
|---------|---------|
| `poly2(T, a, b, c)` | ``a + bT + cT^2`` |
| `poly3(T, a, b, c, d)` | ``a + bT + cT^2 + dT^3`` |
| `poly4(T, a, b, c, d, e)` | ``a + bT + cT^2 + dT^3 + eT^4`` |
| `poly5(T, a, b, c, d, e, f)` | ``a + bT + cT^2 + dT^3 + eT^4 + fT^5`` |

## Polynomials with Reference Temperature

| Pattern | Formula |
|---------|---------|
| `poly2_tref(T, T_{ref}, a, b, c)` | ``a + b(T - T_{ref}) + c(T - T_{ref})^2`` |
| `poly3_tref(T, T_{ref}, a, b, c, d)` | ``a + b(T - T_{ref}) + c(T - T_{ref})^2 + d(T - T_{ref})^3`` |

## Polynomial in τ = T/1000

| Pattern | Formula |
|---------|---------|
| `poly_tau(T, a)` | ``\sum_{i=0}^{n} a_i \tau^i`` where ``\tau = T/1000`` |

The coefficient vector `a` can have arbitrary length.

## Arrhenius Type

| Pattern | Formula |
|---------|---------|
| `arrhenius(T, A, B, R)` | ``A \exp(B / RT)`` |
| `arrhenius_shifted(T, A, B, R, T_0)` | ``A \exp(B / R(T - T_0))`` |

## Exponential Types

| Pattern | Formula |
|---------|---------|
| `exp_linear(T, a, b)` | ``\exp(a + bT)`` |
| `exp_linear_tref(T, a, b, T_{ref})` | ``a \exp(b(T - T_{ref}))`` |
| `exp_BT_CT2(T, A, B, C)` | ``A \exp(B/T + C/T^2)`` |

## Power-Exponential

| Pattern | Formula |
|---------|---------|
| `power_exp(T, a, b, c)` | ``a T^b \exp(c/T)`` |

## Logarithmic Types

| Pattern | Formula |
|---------|---------|
| `log_poly(T, a, b, c)` | ``\exp(a + b \ln T + c/T)`` |
| `log10_linear(T, a, b)` | ``10^{-a + b/T}`` |
| `log10_poly3(T, a, b, c, d)` | ``a + b \log_{10} T + c (\log_{10} T)^2 + d (\log_{10} T)^3`` |

## Concentration Polynomials

Temperature-independent polynomials in concentration ``C`` (mol%):

| Pattern | Formula |
|---------|---------|
| `conc_poly1(C, a, b)` | ``a + bC`` |
| `conc_poly2(C, a, b, c)` | ``a + bC + cC^2`` |
| `conc_poly3(C, a, b, c, d)` | ``a + bC + cC^2 + dC^3`` |
| `conc_poly4(C, a, b, c, d, e)` | ``a + bC + cC^2 + dC^3 + eC^4`` |

## Mixed Temperature-Concentration Patterns

| Pattern | Formula |
|---------|---------|
| `tc_linear(T, x, a, b, c, d)` | ``a + bT + cx + dx^2`` |
| `tc_cross(T, x, a, b, c, d, e)` | ``a + bT + cx + dx^2 T + exT^2`` |

## Special Patterns

| Pattern | Formula |
|---------|---------|
| `reciprocal_linear(T, a, T_{ref})` | ``1 / (a - T)`` |
| `molar_volume_to_density(T, a, b, M, T_{ref})` | ``M / V_m`` where ``V_m = [a(T - T_{ref}) + b] \times 10^{-6}`` |

### Vapour Pressure

| Pattern | Formula |
|---------|---------|
| `vapour_pressure_iaea(T, a, b, c, d)` | ``\exp(a + b/T + c \ln T + dT)`` |
| `vapour_pressure_kelley(T, A, B, C, R)` | ``\exp(-\Delta F / RT)`` where ``\Delta F = A + BT \log_{10} T - CT`` |
| `vapour_pressure_iida(T, A, B, C)` | ``10^{A + B/T + C \log_{10} T}`` |

### Heat Capacity

| Pattern | Formula |
|---------|---------|
| `heat_capacity_polynomial_molar(T, c_{p,0}, a, b, c, M)` | ``(c_{p,0} + aT + bT^2 + cT^{-2}) / M`` |
