# SPDX-License-Identifier: MIT
# Based on yamdb (Copyright 2018-2023 Tom Weier)
# Julia port Copyright (C) 2026 Hiroharu Sugawara

using ...EquationPatterns:
    constant,
    linear,
    linear_tref,
    poly2,
    poly_tau,
    conc_poly1,
    conc_poly2,
    conc_poly3,
    conc_poly4,
    tc_linear,
    tc_cross,
    molar_volume_to_density

function Assaeletal2012(Temp; coef)
    c1 = coef["c1"]
    c2 = coef["c2"]
    Tref = coef["Tref"]
    return c1 - c2 * (Temp - Tref)
end

function Bockrisetal1962(Temp; coef)
    Tref = get(coef, "Tref", 273.15)
    a = coef["a"]
    b = coef["b"]
    c = coef["c"]
    rho = a - b * (Temp - Tref) - c * (Temp - Tref) * (Temp - Tref)
    return rho
end

function DoboszGancarz2018(Temp; coef)
    a_1 = coef["a1"]
    a_2 = coef["a2"]
    return a_1 * Temp + a_2
end

function Hansenetal1990(Temp; coef)
    Tref = get(coef, "Tref", 273.15)
    a = coef["a"]
    b = coef["b"]
    M = coef["M"]
    vm = a * (Temp - Tref) + b
    vm *= 1.0e-6  # cm3/mol -> m3/mol
    rho = M / vm
    return rho
end

function IAEA2008(Temp; coef)
    rho_0 = coef["rho_0"]
    a = coef["a"]
    b = coef["b"]
    c = coef["c"]
    d = coef["d"]
    e = coef["e"]
    t = Temp - 273.15
    # Note: Python code has e*t^3 (not t^4) — appears to be a bug in yamdb
    rho = rho_0 * (a + b * t + c * t^2 + d * t^3 + e * t^3)
    return rho
end

function Janzetal1975TC(Temp, x; coef)
    a = coef["a"]
    b = coef["b"]
    c = coef["c"]
    d = coef["d"]
    rho = a + b * Temp + c * x + d * x^2
    rho *= 1000.0  # g/cm3 -> kg/m3
    return rho
end

function Janzetal1975TC2(Temp, x; coef)
    a = coef["a"]
    b = coef["b"]
    c = coef["c"]
    d = coef["d"]
    e = coef["e"]
    rho = a + b * Temp + c * x + d * x^2 * Temp + e * x * Temp^2
    rho *= 1000.0  # g/cm3 -> kg/m3
    return rho
end

function Shpilrain1985(Temp; coef)
    a = coef["a"]
    rho = 0.0
    tau = Temp / 1000.0
    for (i, c) in enumerate(a)
        rho += c * tau^(i - 1)
    end
    rho *= 1000.0  # -> kg/m3
    return rho
end

function Sobolev2011(Temp; coef)
    rho_s = coef["rho_s"]
    drhodT = coef["drhodT"]
    return rho_s + drhodT * Temp
end

function Steinberg1974(Temp; coef)
    rho_m = coef["rho_m"]
    lambda_ = coef["lambda"]
    Tm = coef["Tm"]
    return rho_m - lambda_ * (Temp - Tm)
end

function Linstrom1992DP(Temp; coef)
    D1 = coef["D1"]
    rho = D1 * 1000.0  # g/cm3 -> kg/m3
    return rho
end

function Linstrom1992P1(Temp; coef)
    D1 = coef["D1"]
    D2 = coef["D2"]
    rho = D1 + D2 * Temp
    rho *= 1000.0  # g/cm3 -> kg/m3
    return rho
end

function Linstrom1992P2(Temp; coef)
    D1 = coef["D1"]
    D2 = coef["D2"]
    D3 = coef["D3"]
    rho = D1 + D2 * Temp + D3 * Temp^2
    rho *= 1000.0  # g/cm3 -> kg/m3
    return rho
end

function Linstrom1992I1(Temp, x; coef)
    D1 = coef["D1"]
    D2 = coef["D2"]
    component = coef["component"]
    C = component == "second" ? 100.0 - x : x
    rho = D1 + D2 * C
    rho *= 1000.0  # g/cm3 -> kg/m3
    return rho
end

function Linstrom1992I2(Temp, x; coef)
    D1 = coef["D1"]
    D2 = coef["D2"]
    D3 = coef["D3"]
    component = coef["component"]
    C = component == "second" ? 100.0 - x : x
    rho = D1 + D2 * C + D3 * C^2
    rho *= 1000.0  # g/cm3 -> kg/m3
    return rho
end

function Linstrom1992I3(Temp, x; coef)
    D1 = coef["D1"]
    D2 = coef["D2"]
    D3 = coef["D3"]
    D4 = coef["D4"]
    component = coef["component"]
    C = component == "second" ? 100.0 - x : x
    rho = D1 + D2 * C + D3 * C^2 + D4 * C^3
    rho *= 1000.0  # g/cm3 -> kg/m3
    return rho
end

function Linstrom1992I4(Temp, x; coef)
    D1 = coef["D1"]
    D2 = coef["D2"]
    D3 = coef["D3"]
    D4 = coef["D4"]
    D5 = coef["D5"]
    component = coef["component"]
    C = component == "second" ? 100.0 - x : x
    rho = D1 + D2 * C + D3 * C^2 + D4 * C^3 + D5 * C^4
    rho *= 1000.0  # g/cm3 -> kg/m3
    return rho
end
