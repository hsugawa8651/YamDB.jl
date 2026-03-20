# SPDX-License-Identifier: MIT
# Based on yamdb (Copyright 2018-2023 Tom Weier)
# Julia port Copyright (C) 2026 Hiroharu Sugawara

# Generic equation patterns for thermophysical property calculations.
# Each pattern is a reusable mathematical function that paper-name
# wrapper functions call with specific coefficients.

# --- Constant ---

constant(val) = val

# --- Linear ---

linear(T, a, b) = a + b * T
linear_tref(T, a, b, Tref) = a - b * (T - Tref)

# --- Polynomials in T ---

poly2(T, a, b, c) = a + b * T + c * T^2
poly3(T, a, b, c, d) = a + b * T + c * T^2 + d * T^3
poly4(T, a, b, c, d, e) = a + b * T + c * T^2 + d * T^3 + e * T^4
poly5(T, a, b, c, d, e, f) = a + b * T + c * T^2 + d * T^3 + e * T^4 + f * T^5

# --- Polynomials with reference temperature ---

poly2_tref(T, Tref, a, b, c) = a + b * (T - Tref) + c * (T - Tref)^2
poly3_tref(T, Tref, a, b, c, d) =
    a + b * (T - Tref) + c * (T - Tref)^2 + d * (T - Tref)^3

# --- Polynomial in tau = T/1000 ---

function poly_tau(T, a::AbstractVector)
    tau = T / 1000.0
    result = zero(promote_type(typeof(T), Float64))
    for (i, c) in enumerate(a)
        result += c * tau^(i - 1)
    end
    return result
end

# --- Arrhenius type ---

arrhenius(T, A, B, R) = A * exp(B / (R * T))
arrhenius_shifted(T, A, B, R, T0) = A * exp(B / (R * (T - T0)))

# --- Exponential types ---

exp_linear(T, a, b) = exp(a + b * T)
exp_linear_tref(T, a, b, Tref) = a * exp(b * (T - Tref))
exp_BT_CT2(T, A, B, C) = A * exp(B / T + C / T^2)

# --- Power-exponential ---

power_exp(T, a, b, c) = a * T^b * exp(c / T)

# --- Logarithmic types ---

log_poly(T, a, b, c) = exp(a + b * log(T) + c / T)
log10_linear(T, a, b) = 10.0^(-a + b / T)

# --- Concentration polynomials (T-independent, in mol%) ---

conc_poly1(C, a, b) = a + b * C
conc_poly2(C, a, b, c) = a + b * C + c * C^2
conc_poly3(C, a, b, c, d) = a + b * C + c * C^2 + d * C^3
conc_poly4(C, a, b, c, d, e) = a + b * C + c * C^2 + d * C^3 + e * C^4

# --- Mixed T-C patterns ---

tc_linear(T, x, a, b, c, d) = a + b * T + c * x + d * x^2
tc_cross(T, x, a, b, c, d, e) = a + b * T + c * x + d * x^2 * T + e * x * T^2

# --- Special patterns ---

reciprocal_linear(T, a, Tref) = 1.0 / (a - T)

function molar_volume_to_density(T, a, b, M, Tref)
    vm = a * (T - Tref) + b
    vm *= 1.0e-6  # cm3/mol -> m3/mol
    return M / vm
end

function log10_poly3(T, a, b, c, d)
    logT = log10(T)
    return a + b * logT + c * logT^2 + d * logT^3
end

function vapour_pressure_iaea(T, a, b, c, d)
    return exp(a + b / T + c * log(T) + d * T)
end

function vapour_pressure_kelley(T, A, B, C, R)
    deltaF = A + B * T * log10(T) - C * T
    return exp(-deltaF / (R * T))
end

function vapour_pressure_iida(T, A, B, C)
    return 10.0^(A + B / T + C * log10(T))
end

function heat_capacity_polynomial_molar(T, cp_0, a, b, c, M)
    cp_mol = cp_0 + a * T + b * T^2 + c * T^(-2)
    return cp_mol / M
end
