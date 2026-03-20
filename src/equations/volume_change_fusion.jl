# SPDX-License-Identifier: MIT
# Based on yamdb (Copyright 2018-2023 Tom Weier)
# Julia port Copyright (C) 2026 Hiroharu Sugawara

using ...EquationPatterns

function SchinkeSauerwald1956(; coef)
    dV = coef["dV"]
    return dV
end
