# SPDX-License-Identifier: MIT
# Based on yamdb (Copyright 2018-2023 Tom Weier)
# Julia port Copyright (C) 2026 Hiroharu Sugawara

using ...EquationPatterns

function IAEA2008(Temp; coef)
    a = coef["a"]
    b = coef["b"]
    c = coef["c"]
    sigma = a + b * (Temp + c)
    sigma /= 1000.0  # mN/m -> N/m
    return sigma
end

function Sobolev2011(Temp; coef)
    a = coef["a"]
    b = coef["b"]
    sigma = a + b * Temp
    sigma /= 1000.0  # mN/m -> N/m
    return sigma
end

function Linstrom1992DP(Temp; coef)
    D1 = coef["D1"]
    return D1 / 1000.0  # mN/m -> N/m
end

function Linstrom1992P1(Temp; coef)
    D1 = coef["D1"]
    D2 = coef["D2"]
    sigma = D1 + D2 * Temp
    sigma /= 1000.0  # mN/m -> N/m
    return sigma
end

function Linstrom1992P2(Temp; coef)
    D1 = coef["D1"]
    D2 = coef["D2"]
    D3 = coef["D3"]
    sigma = D1 + D2 * Temp + D3 * Temp^2
    sigma /= 1000.0  # mN/m -> N/m
    return sigma
end

function Linstrom1992I1(Temp, x; coef)
    D1 = coef["D1"]
    D2 = coef["D2"]
    component = coef["component"]
    C = component == "second" ? 100.0 - x : x
    sigma = D1 + D2 * C
    sigma /= 1000.0  # mN/m -> N/m
    return sigma
end

function Linstrom1992I2(Temp, x; coef)
    D1 = coef["D1"]
    D2 = coef["D2"]
    D3 = coef["D3"]
    component = coef["component"]
    C = component == "second" ? 100.0 - x : x
    sigma = D1 + D2 * C + D3 * C^2
    sigma /= 1000.0  # mN/m -> N/m
    return sigma
end

function Linstrom1992I3(Temp, x; coef)
    D1 = coef["D1"]
    D2 = coef["D2"]
    D3 = coef["D3"]
    D4 = coef["D4"]
    component = coef["component"]
    C = component == "second" ? 100.0 - x : x
    sigma = D1 + D2 * C + D3 * C^2 + D4 * C^3
    sigma /= 1000.0  # mN/m -> N/m
    return sigma
end

function Linstrom1992I4(Temp, x; coef)
    D1 = coef["D1"]
    D2 = coef["D2"]
    D3 = coef["D3"]
    D4 = coef["D4"]
    D5 = coef["D5"]
    component = coef["component"]
    C = component == "second" ? 100.0 - x : x
    sigma = D1 + D2 * C + D3 * C^2 + D4 * C^3 + D5 * C^4
    sigma /= 1000.0  # mN/m -> N/m
    return sigma
end
