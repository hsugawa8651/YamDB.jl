# SPDX-License-Identifier: MIT
# Based on yamdb (Copyright 2018-2023 Tom Weier)
# Julia port Copyright (C) 2026 Hiroharu Sugawara

using ...EquationPatterns

function IAEA2008(Temp; coef)
    a = coef["a"]
    b = coef["b"]
    c = coef["c"]
    d = coef["d"]
    pv = a + b / Temp + c * log(Temp) + d * Temp
    pv = exp(pv)
    return pv
end

function IidaGuthrie2015(Temp; coef)
    A = coef["A"]
    B = coef["B"]
    C = coef["C"]
    unit = get(coef, "unit", "atm")
    pv = A + B / Temp + C * log10(Temp)
    pv = 10.0^pv
    if unit == "mmHg"
        pv *= 133.322  # mmHg -> Pa
    elseif unit == "Pa"
        # no conversion
    else
        pv *= 101325.0  # atm -> Pa
    end
    return pv
end

function Kelley1935(Temp; coef)
    A = coef["A"]
    B = coef["B"]
    C = coef["C"]
    R = 1.9869  # cal/K
    deltaF = A + B * Temp * log10(Temp) - C * Temp
    pv = exp(-deltaF / (R * Temp))
    pv *= 101325.0  # atm -> Pa
    return pv
end

function Ohse1985(Temp; coef)
    A = coef["A"]
    B = coef["B"]
    C = coef["C"]
    pv = A + B / Temp + C * log(Temp)
    pv = exp(pv)
    pv *= 1e06  # MPa -> Pa
    return pv
end

function Sobolev2011(Temp; coef)
    a = coef["a"]
    b = coef["b"]
    pv = a * exp(b / Temp)
    return pv
end

function Villadaetal2021(Temp; coef)
    a = coef["a"]
    b = coef["b"]
    Tref = coef["Tref"]
    pv = a * exp(b * (Temp - Tref))
    pv *= 1000.0  # kPa -> Pa
    return pv
end

function Wangetal2021(Temp; coef)
    a = coef["a"]
    b = coef["b"]
    c = coef["c"]
    d = coef["d"]
    Tref = coef["Tref"]
    pv = a + b * (Temp - Tref) + c * (Temp - Tref)^2 + d * (Temp - Tref)^3
    pv *= 1000.0  # kPa -> Pa
    return pv
end
