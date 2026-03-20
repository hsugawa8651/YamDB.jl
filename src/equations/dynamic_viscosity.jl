# SPDX-License-Identifier: MIT
# Based on yamdb (Copyright 2018-2023 Tom Weier)
# Julia port Copyright (C) 2026 Hiroharu Sugawara

using ...EquationPatterns

function Assaeletal2012(Temp; coef)
    a1 = coef["a1"]
    a2 = coef["a2"]
    eta = -a1 + a2 / Temp
    eta = 10.0^eta
    eta /= 1000.0
    return eta
end

function Hirai1992(Temp; coef)
    R = 8.3144  # J mol^-1 K^-1
    A = coef["A"]
    B = coef["B"]
    eta = A * exp(B * 1000.0 / (R * Temp))  # kJ -> J in B
    eta /= 1000.0  # mPa s -> Pa s
    return eta
end

function IAEA2008(Temp; coef)
    a = coef["a"]
    b = coef["b"]
    c = coef["c"]
    eta = a * Temp^b * exp(c / Temp)
    return eta
end

function Janzetal1968(Temp; coef)
    c = get(coef, "c", 0.0)
    d = get(coef, "d", 0.0)
    Tref = get(coef, "Tref", 0.0)
    a = coef["a"]
    b = coef["b"]
    eta = a + b * (Temp - Tref) + c * (Temp - Tref)^2 + d * (Temp - Tref)^3
    eta /= 1000.0  # mPa s -> Pa s
    return eta
end

function Janzetal1968exp(Temp; coef)
    R = 1.98717  # cal mol^-1 deg^-1
    A = coef["A"]
    E = coef["E"]
    eta = A * exp(E / (R * Temp))
    eta /= 1000.0  # mPa s -> Pa s
    return eta
end

function KostalMalek2010(Temp; coef)
    A = coef["A"]
    B = coef["B"]
    T0 = coef["T0"]
    eta = A + B / (Temp - T0)
    eta = exp(eta)
    return eta  # already in Pa s
end

function Ohse1985(Temp; coef)
    a = coef["a"]
    b = coef["b"]
    c = coef["c"]
    eta = a + b * log(Temp) + c / Temp
    eta = exp(eta)
    return eta  # already in Pa s
end

function Linstrom1992plusE(Temp; coef)
    R = get(coef, "R", 8.31441)
    D1 = coef["D1"]
    D2 = coef["D2"]
    eta = D1 * exp(D2 / (R * Temp))
    eta /= 1000.0  # mPa s -> Pa s
    return eta
end

function Linstrom1992DP(Temp; coef)
    D1 = coef["D1"]
    eta = D1 / 1000.0  # mPa s -> Pa s
    return eta
end

function Linstrom1992E1(Temp; coef)
    R = 8.31441
    D1 = coef["D1"]
    D2 = coef["D2"]
    D3 = coef["D3"]
    eta = D1 * exp(D2 / (R * Temp)) + D3 / Temp^2
    eta /= 1000.0  # mPa s -> Pa s
    return eta
end

function Linstrom1992E2(Temp; coef)
    R = 8.31441
    D1 = coef["D1"]
    D2 = coef["D2"]
    D3 = coef["D3"]
    eta = D1 * exp(D2 / (R * (Temp - D3)))
    eta /= 1000.0  # mPa s -> Pa s
    return eta
end

function Linstrom1992P2(Temp; coef)
    D1 = coef["D1"]
    D2 = coef["D2"]
    D3 = coef["D3"]
    eta = D1 + D2 * Temp + D3 * Temp^2
    eta /= 1000.0  # mPa s -> Pa s
    return eta
end

function Linstrom1992P3(Temp; coef)
    D1 = coef["D1"]
    D2 = coef["D2"]
    D3 = coef["D3"]
    D4 = coef["D4"]
    eta = D1 + D2 * Temp + D3 * Temp^2 + D4 * Temp^3
    eta /= 1000.0  # mPa s -> Pa s
    return eta
end

function Linstrom1992I1(Temp, x; coef)
    D1 = coef["D1"]
    D2 = coef["D2"]
    component = coef["component"]
    C = component == "second" ? 100.0 - x : x
    eta = D1 + D2 * C
    eta /= 1000.0  # mPa s -> Pa s
    return eta
end

function Linstrom1992I2(Temp, x; coef)
    D1 = coef["D1"]
    D2 = coef["D2"]
    D3 = coef["D3"]
    component = coef["component"]
    C = component == "second" ? 100.0 - x : x
    eta = D1 + D2 * C + D3 * C^2
    eta /= 1000.0  # mPa s -> Pa s
    return eta
end

function Linstrom1992I3(Temp, x; coef)
    D1 = coef["D1"]
    D2 = coef["D2"]
    D3 = coef["D3"]
    D4 = coef["D4"]
    component = coef["component"]
    C = component == "second" ? 100.0 - x : x
    eta = D1 + D2 * C + D3 * C^2 + D4 * C^3
    eta /= 1000.0  # mPa s -> Pa s
    return eta
end

function Linstrom1992I4(Temp, x; coef)
    D1 = coef["D1"]
    D2 = coef["D2"]
    D3 = coef["D3"]
    D4 = coef["D4"]
    D5 = coef["D5"]
    component = coef["component"]
    C = component == "second" ? 100.0 - x : x
    eta = D1 + D2 * C + D3 * C^2 + D4 * C^3 + D5 * C^4
    eta /= 1000.0  # mPa s -> Pa s
    return eta
end

function ToerklepOeye1982(Temp; coef)
    A = coef["A"]
    B = coef["B"]
    C = coef["C"]
    eta = A * exp(B / Temp + C / Temp^2)
    eta /= 1000.0  # mPa s -> Pa s
    return eta
end

function Villadaetal2021(Temp; coef)
    a = coef["a"]
    b = coef["b"]
    Tref = coef["Tref"]
    eta = a * exp(b * (Temp - Tref))
    eta /= 1000.0  # mPa s -> Pa s
    return eta
end
