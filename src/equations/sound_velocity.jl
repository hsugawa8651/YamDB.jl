# SPDX-License-Identifier: MIT
# Based on yamdb (Copyright 2018-2023 Tom Weier)
# Julia port Copyright (C) 2026 Hiroharu Sugawara

using ...EquationPatterns

function Blairs2007(Temp; coef)
    A = coef["A"]
    B = coef["B"]
    return A + B * Temp
end

function Blairs2007cubic(Temp; coef)
    A = coef["A"]
    B = coef["B"]
    C = coef["C"]
    return A + B * Temp + C * Temp * Temp
end

function IAEA2008(Temp; coef)
    a = coef["a"]
    b = coef["b"]
    c = coef["c"]
    v = a + b / Temp + c * (Temp - 273.15)
    return v
end

function linearExperimental(Temp; coef)
    Um = coef["Um"]
    m_dUdT = coef["m_dUdT"]
    Tm = coef["Tm"]
    U = Um - (Temp - Tm) * m_dUdT
    return U
end
