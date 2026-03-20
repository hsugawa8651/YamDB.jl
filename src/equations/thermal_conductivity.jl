# SPDX-License-Identifier: MIT
# Based on yamdb (Copyright 2018-2023 Tom Weier)
# Julia port Copyright (C) 2026 Hiroharu Sugawara

using ...EquationPatterns

function Assaeletal2017(Temp; coef)
    c1 = coef["c1"]
    c2 = coef["c2"]
    Tm = coef["Tm"]
    lambda_ = c1 + c2 * (Temp - Tm)
    return lambda_
end

function Chliatzouetal2018(Temp; coef)
    c0 = coef["c0"]
    c1 = coef["c1"]
    Tm = coef["Tm"]
    lambda_ = c0 + c1 * (Temp - Tm)
    lambda_ /= 1000.0  # mW/(m K) -> W/(m K)
    return lambda_
end

function IAEA2008(Temp; coef)
    a = coef["a"]
    b = coef["b"]
    c = coef["c"]
    t = Temp - 273.15
    lambda_ = a + b * t + c * t^2
    return lambda_
end

function Sobolev2011(Temp; coef)
    a = coef["a"]
    b = coef["b"]
    c = coef["c"]
    lambda_ = a + b * Temp + c * Temp^2
    return lambda_
end

function SquareRoot(Temp; coef)
    a = coef["a"]
    b = coef["b"]
    c = coef["c"]
    lambda_ = a + b * Temp + c * Temp^0.5
    return lambda_
end

function Touloukian1970b(Temp; coef)
    a = coef["a"]
    b = coef["b"]
    lambda_ = a + b * Temp
    return lambda_
end
