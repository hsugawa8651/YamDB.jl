# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hiroharu Sugawara

using Test
using YamDB: EquationPatterns as EP

@testset "EquationPatterns" begin
    @testset "constant" begin
        @test EP.constant(42.0) == 42.0
        @test EP.constant(0.0) == 0.0
    end

    @testset "linear" begin
        @test EP.linear(500.0, 10.0, -0.5) == 10.0 + (-0.5) * 500.0
        @test EP.linear(0.0, 3.0, 2.0) == 3.0
    end

    @testset "linear_tref" begin
        # a - b*(T - Tref)
        @test EP.linear_tref(500.0, 900.0, 0.2, 371.0) == 900.0 - 0.2 * (500.0 - 371.0)
        @test EP.linear_tref(371.0, 900.0, 0.2, 371.0) == 900.0
    end

    @testset "polynomials" begin
        T = 800.0
        @test EP.poly2(T, 1.0, 2.0, 3.0) == 1.0 + 2.0 * T + 3.0 * T^2
        @test EP.poly3(T, 1.0, 2.0, 3.0, 4.0) ==
              1.0 + 2.0 * T + 3.0 * T^2 + 4.0 * T^3
        @test EP.poly4(T, 1.0, 2.0, 3.0, 4.0, 5.0) ==
              1.0 + 2.0 * T + 3.0 * T^2 + 4.0 * T^3 + 5.0 * T^4
        @test EP.poly5(T, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0) ==
              1.0 + 2.0 * T + 3.0 * T^2 + 4.0 * T^3 + 5.0 * T^4 + 6.0 * T^5
    end

    @testset "poly_tref" begin
        T = 700.0
        Tref = 273.15
        dT = T - Tref
        @test EP.poly2_tref(T, Tref, 1.0, 2.0, 3.0) == 1.0 + 2.0 * dT + 3.0 * dT^2
        @test EP.poly3_tref(T, Tref, 1.0, 2.0, 3.0, 4.0) ==
              1.0 + 2.0 * dT + 3.0 * dT^2 + 4.0 * dT^3
    end

    @testset "poly_tau" begin
        T = 1500.0
        a = [100.0, -50.0, 10.0]
        tau = T / 1000.0
        expected = 100.0 + (-50.0) * tau + 10.0 * tau^2
        @test EP.poly_tau(T, a) == expected
    end

    @testset "arrhenius" begin
        T = 800.0
        A = 0.1
        B = 5000.0
        R = 8.31441
        @test EP.arrhenius(T, A, B, R) == A * exp(B / (R * T))
    end

    @testset "arrhenius_shifted" begin
        T = 800.0
        A = 0.1
        B = 5000.0
        R = 8.31441
        T0 = 100.0
        @test EP.arrhenius_shifted(T, A, B, R, T0) == A * exp(B / (R * (T - T0)))
    end

    @testset "exponential types" begin
        T = 600.0
        @test EP.exp_linear(T, -5.0, 0.001) == exp(-5.0 + 0.001 * T)
        @test EP.exp_linear_tref(T, 0.5, -0.01, 500.0) ==
              0.5 * exp(-0.01 * (T - 500.0))
        @test EP.exp_BT_CT2(T, 0.1, 100.0, -50000.0) ==
              0.1 * exp(100.0 / T + (-50000.0) / T^2)
    end

    @testset "power_exp" begin
        T = 700.0
        @test EP.power_exp(T, 0.001, -0.5, 1000.0) ==
              0.001 * T^(-0.5) * exp(1000.0 / T)
    end

    @testset "logarithmic types" begin
        T = 900.0
        @test EP.log_poly(T, -5.0, 1.5, -3000.0) ==
              exp(-5.0 + 1.5 * log(T) + (-3000.0) / T)
        @test EP.log10_linear(T, 2.0, 5000.0) == 10.0^(-2.0 + 5000.0 / T)
    end

    @testset "concentration polynomials" begin
        C = 30.0
        @test EP.conc_poly1(C, 1.0, 0.5) == 1.0 + 0.5 * C
        @test EP.conc_poly2(C, 1.0, 0.5, -0.01) == 1.0 + 0.5 * C + (-0.01) * C^2
        @test EP.conc_poly3(C, 1.0, 0.5, -0.01, 0.001) ==
              1.0 + 0.5 * C + (-0.01) * C^2 + 0.001 * C^3
        @test EP.conc_poly4(C, 1.0, 0.5, -0.01, 0.001, -1e-5) ==
              1.0 + 0.5 * C + (-0.01) * C^2 + 0.001 * C^3 + (-1e-5) * C^4
    end

    @testset "mixed T-C patterns" begin
        T = 800.0
        x = 30.0
        @test EP.tc_linear(T, x, 1.0, 0.01, 0.5, -0.001) ==
              1.0 + 0.01 * T + 0.5 * x + (-0.001) * x^2
        @test EP.tc_cross(T, x, 1.0, 0.01, 0.5, -0.001, 1e-5) ==
              1.0 + 0.01 * T + 0.5 * x + (-0.001) * x^2 * T + 1e-5 * x * T^2
    end

    @testset "special patterns" begin
        @test EP.reciprocal_linear(500.0, 2000.0, 0.0) == 1.0 / (2000.0 - 500.0)

        # molar_volume_to_density: vm = a*(T-Tref) + b; vm *= 1e-6; rho = M/vm
        T = 700.0
        a = 0.01
        b = 20.0
        M = 0.1
        Tref = 273.15
        vm = (a * (T - Tref) + b) * 1e-6
        @test EP.molar_volume_to_density(T, a, b, M, Tref) == M / vm
    end

    @testset "vapour_pressure patterns" begin
        T = 1000.0
        @test EP.vapour_pressure_iaea(T, 1.0, -5000.0, 0.5, 0.001) ==
              exp(1.0 + (-5000.0) / T + 0.5 * log(T) + 0.001 * T)

        # Kelley: deltaF = A + B*T*log10(T) - C*T; pv = exp(-deltaF/(R*T))
        A = 10000.0
        B = -5.0
        C = 20.0
        R = 1.9869
        deltaF = A + B * T * log10(T) - C * T
        @test EP.vapour_pressure_kelley(T, A, B, C, R) == exp(-deltaF / (R * T))

        @test EP.vapour_pressure_iida(T, 5.0, -8000.0, -1.5) ==
              10.0^(5.0 + (-8000.0) / T + (-1.5) * log10(T))
    end

    @testset "heat_capacity_polynomial_molar" begin
        T = 800.0
        cp_0 = 30.0
        a = 0.01
        b = -1e-5
        c = 1e6
        M = 0.023  # kg/mol (Na)
        cp_mol = cp_0 + a * T + b * T^2 + c * T^(-2)
        @test EP.heat_capacity_polynomial_molar(T, cp_0, a, b, c, M) == cp_mol / M
    end

    @testset "log10_poly3" begin
        T = 1000.0
        logT = log10(T)
        @test EP.log10_poly3(T, 1.0, 2.0, 3.0, 4.0) ==
              1.0 + 2.0 * logT + 3.0 * logT^2 + 4.0 * logT^3
    end
end
