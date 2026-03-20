# SPDX-License-Identifier: MIT
# Based on yamdb (Copyright 2018-2023 Tom Weier)
# Julia port Copyright (C) 2026 Hiroharu Sugawara

using ...EquationPatterns

function Baker1968(Temp; coef)
    A = coef["A"]
    B = coef["B"]
    logrho_e = A / Temp - B
    rho_e = 10.0^logrho_e
    rho_e /= 100.0  # Ohm cm -> Ohm m
    return rho_e
end

function constant(Temp; coef)
    return coef["value"] * Temp / Temp
end

function CusackEnderby1960(Temp; coef)
    alpha = coef["alpha"]
    beta = coef["beta"]
    return alpha * Temp + beta
end

function Desaietal1984(Temp; coef)
    a = coef["a"]
    b = coef["b"]
    c = coef["c"]
    d = coef["d"]
    rho_e = a + b * Temp + c * Temp^2 + d * Temp^3
    rho_e *= 1e-08  # 10^-8 Ohm m -> Ohm m
    return rho_e
end

function fractionalNegativeExponent(Temp; coef)
    a = coef["a"]
    b = coef["b"]
    c = coef["c"]
    return a + b / Temp^c
end

function IAEA2008(Temp; coef)
    a = coef["a"]
    b = coef["b"]
    c = coef["c"]
    d = coef["d"]
    e = coef["e"]
    f = coef["f"]
    rho_e0 = coef["rho_e0"]
    t = Temp - 273.15
    rho_e = (a + b * t + c * t^2 + d * t^3 + e * t^4 + f * t^5) * rho_e0
    return rho_e
end

function Janzetal1968(Temp; coef)
    a = coef["a"]
    b = coef["b"]
    c = get(coef, "c", 0.0)
    d = get(coef, "d", 0.0)
    Tref = get(coef, "Tref", 0.0)
    kappa = a + b * (Temp - Tref) + c * (Temp - Tref)^2 + d * (Temp - Tref)^3
    kappa *= 100.0  # 1/(Ohm cm) -> 1/(Ohm m)
    return 1.0 / kappa
end

function Janz1967exp(Temp; coef)
    R = 1.98717e-03  # kcal/(mol K)
    A = coef["A"]
    E = coef["E"]
    kappa = A * exp(-E / (R * Temp))
    kappa *= 100.0  # 1/(Ohm cm) -> 1/(Ohm m)
    return 1.0 / kappa
end

function Linstrom1992plusE(Temp; coef)
    R = 8.31441
    D1 = coef["D1"]
    D2 = coef["D2"]
    kappa = D1 * exp(D2 / (R * Temp))
    kappa *= 100.0  # 1/(Ohm cm) -> 1/(Ohm m)
    return 1.0 / kappa
end

function Linstrom1992DP(Temp; coef)
    D1 = coef["D1"]
    kappa = D1 * 100.0  # 1/(Ohm cm) -> 1/(Ohm m)
    return 1.0 / kappa
end

function Linstrom1992E2(Temp; coef)
    R = 8.31441
    D1 = coef["D1"]
    D2 = coef["D2"]
    D3 = coef["D3"]
    kappa = D1 * exp(D2 / (R * (Temp - D3)))
    kappa *= 100.0  # 1/(Ohm cm) -> 1/(Ohm m)
    return 1.0 / kappa
end

function Linstrom1992P1(Temp; coef)
    D1 = coef["D1"]
    D2 = coef["D2"]
    kappa = D1 + D2 * Temp
    kappa *= 100.0  # 1/(Ohm cm) -> 1/(Ohm m)
    return 1.0 / kappa
end

function Linstrom1992P2(Temp; coef)
    D1 = coef["D1"]
    D2 = coef["D2"]
    D3 = coef["D3"]
    kappa = D1 + D2 * Temp + D3 * Temp^2
    kappa *= 100.0  # 1/(Ohm cm) -> 1/(Ohm m)
    return 1.0 / kappa
end

function Linstrom1992P3(Temp; coef)
    D1 = coef["D1"]
    D2 = coef["D2"]
    D3 = coef["D3"]
    D4 = coef["D4"]
    kappa = D1 + D2 * Temp + D3 * Temp^2 + D4 * Temp^3
    kappa *= 100.0  # 1/(Ohm cm) -> 1/(Ohm m)
    return 1.0 / kappa
end

function Linstrom1992P4(Temp; coef)
    D1 = coef["D1"]
    D2 = coef["D2"]
    D3 = coef["D3"]
    D4 = coef["D4"]
    D5 = coef["D5"]
    kappa = D1 + D2 * Temp + D3 * Temp^2 + D4 * Temp^3 + D5 * Temp^4
    kappa *= 100.0  # 1/(Ohm cm) -> 1/(Ohm m)
    return 1.0 / kappa
end

function Linstrom1992I1(Temp, x; coef)
    D1 = coef["D1"]
    D2 = coef["D2"]
    component = coef["component"]
    C = component == "second" ? 100.0 - x : x
    kappa = D1 + D2 * C
    kappa *= 100.0
    return 1.0 / kappa
end

function Linstrom1992I2(Temp, x; coef)
    D1 = coef["D1"]
    D2 = coef["D2"]
    D3 = coef["D3"]
    component = coef["component"]
    C = component == "second" ? 100.0 - x : x
    kappa = D1 + D2 * C + D3 * C^2
    kappa *= 100.0
    return 1.0 / kappa
end

function Linstrom1992I3(Temp, x; coef)
    D1 = coef["D1"]
    D2 = coef["D2"]
    D3 = coef["D3"]
    D4 = coef["D4"]
    component = coef["component"]
    C = component == "second" ? 100.0 - x : x
    kappa = D1 + D2 * C + D3 * C^2 + D4 * C^3
    kappa *= 100.0
    return 1.0 / kappa
end

function Linstrom1992I4(Temp, x; coef)
    D1 = coef["D1"]
    D2 = coef["D2"]
    D3 = coef["D3"]
    D4 = coef["D4"]
    D5 = coef["D5"]
    component = coef["component"]
    C = component == "second" ? 100.0 - x : x
    kappa = D1 + D2 * C + D3 * C^2 + D4 * C^3 + D5 * C^4
    kappa *= 100.0
    return 1.0 / kappa
end

function Massetetal2006(Temp; coef)
    A = coef["A"]
    E = coef["E"]
    kappa = A * exp(E / Temp)
    kappa *= 100.0  # 1/(Ohm cm) -> 1/(Ohm m)
    return 1.0 / kappa
end

function Ohse1985(Temp; coef)
    ranges = coef["range"]
    n = length(ranges)
    # Python logic: start at last segment, iterate backwards,
    # pick segment i if Temp < Tmax[i]. Extrapolates if outside all ranges.
    idx = n
    for i in n:-1:1
        if Temp < ranges[i]["Tmax"]
            idx = i
        end
    end
    # Clamp to valid range
    idx = clamp(idx, 1, n)
    return _Ohse1985_func(Temp, ranges[idx]) * 1e-08  # 10^-8 Ohm m -> Ohm m
end

function _Ohse1985_func(Temp, r)
    a = r["a"]
    b = r["b"]
    c = r["c"]
    d = r["d"]
    Tmin = r["Tmin"]
    logT = log10(Temp / Tmin)
    logrho_e = a + b * logT + c * logT^2 + d * logT^3
    return 10.0^logrho_e
end

function SalyulevPotapov2015(Temp; coef)
    a = coef["a"]
    b = coef["b"]
    c = coef["c"]
    d = coef["d"]
    logkappa = a + b / Temp + c / Temp^2 + d / Temp^3
    kappa = 10.0^logkappa
    kappa *= 100.0  # S/cm -> S/m
    return 1.0 / kappa
end

function Sobolev2011(Temp; coef)
    a = coef["a"]
    b = coef["b"]
    c = coef["c"]
    return a + b * Temp + c * Temp^2
end

function Zinkle1998(Temp; coef)
    a = coef["a"]
    b = coef["b"]
    c = coef["c"]
    d = coef["d"]
    e = coef["e"]
    rho_e = a + b * Temp + c * Temp^2 + d * Temp^3 + e * Temp^4
    rho_e *= 1e-09  # nOhm m -> Ohm m
    return rho_e
end
