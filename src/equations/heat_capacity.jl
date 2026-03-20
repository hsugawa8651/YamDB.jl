# SPDX-License-Identifier: MIT
# Based on yamdb (Copyright 2018-2023 Tom Weier)
# Julia port Copyright (C) 2026 Hiroharu Sugawara

using ...EquationPatterns

function Gurvich1991(Temp; coef)
    cp_0 = coef["cp_0"]
    a = coef["a"]
    b = coef["b"]
    c = coef["c"]
    d = coef["d"]
    cp = cp_0 + a * Temp + b * Temp^2 + c * Temp^3 + d / Temp^2
    return cp
end

function IAEA2008(Temp; coef)
    cp_0 = coef["cp_0"]
    a = coef["a"]
    b = coef["b"]
    c = coef["c"]
    cp = cp_0 + a * Temp + b * Temp^2 + c / Temp
    return cp * 1000.0  # kJ -> J
end

function IidaGuthrie1988(Temp; coef)
    cp_mol = coef["cp_mol"]
    M = coef["M"]
    energy_unit = get(coef, "energy_unit", "J")
    if energy_unit == "cal"
        cp_mol *= 4.184  # cal -> J
    end
    cp = cp_mol / M
    return cp * Temp / Temp
end

function IidaGuthrie2015(Temp; coef)
    cp_0 = coef["cp_0"]
    a = coef["a"]
    b = coef["b"]
    c = coef["c"]
    M = coef["M"]
    energy_unit = get(coef, "energy_unit", "J")
    cp_mol = cp_0 + a * Temp + b * Temp^2 + c * Temp^(-2.0)
    if energy_unit == "cal"
        cp_mol *= 4.184  # cal -> J
    end
    cp = cp_mol / M
    return cp
end

function Imbeni1998(Temp; coef)
    cp_0 = coef["cp_0"]
    a = coef["a"]
    b = coef["b"]
    cp = cp_0 + a * Temp + b / Temp^2
    return cp
end

function Ohse1985(Temp; coef)
    C1 = coef["C1"]
    C2 = coef["C2"]
    C3 = coef["C3"]
    M = coef["M"]
    cp_mol = C1 + C2 * Temp + C3 * Temp^2
    cp = cp_mol / M
    return cp
end

function Sobolev2011(Temp; coef)
    cp_0 = coef["cp_0"]
    a = coef["a"]
    b = coef["b"]
    c = coef["c"]
    cp = cp_0 + a * Temp + b * Temp^2 + c / Temp^2
    return cp
end
