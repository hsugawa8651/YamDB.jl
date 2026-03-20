# SPDX-License-Identifier: MIT
# Based on yamdb (Copyright 2018-2023 Tom Weier)
# Julia port Copyright (C) 2026 Hiroharu Sugawara

using ...EquationPatterns

function IAEA2008(Temp; coef)
    a = coef["a"]
    b = coef["b"]
    c = coef["c"]
    d = coef["d"]
    t = Temp - 273.15
    beta = a + b * t + c * t^2 + d * t^3
    beta /= 1.0e04
    return beta
end

function OECDNEA2015(Temp; coef)
    a = coef["a"]
    beta = 1.0 / (a - Temp)
    return beta
end

function Steinberg1974(Temp; coef)
    rho_m = coef["rho_m"]
    lambda_ = coef["lambda"]
    Tm = coef["Tm"]
    rho = rho_m - lambda_ * (Temp - Tm)
    beta = lambda_ / rho
    return beta
end

function Sobolev2011(Temp; coef)
    rho_s = coef["rho_s"]
    drhodT = coef["drhodT"]
    rho = rho_s + drhodT * Temp
    return -drhodT / rho
end
