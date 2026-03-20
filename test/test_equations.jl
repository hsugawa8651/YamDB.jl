# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hiroharu Sugawara
# Part of YamDB.jl
#
# Smoke tests for paper-name equation functions.
# One representative function per module, values from Level 0 reftest JSON.

using Test

const Density = YamDB.Equations.Density
const DynamicViscosity = YamDB.Equations.DynamicViscosity
const Resistivity = YamDB.Equations.Resistivity
const SurfaceTension = YamDB.Equations.SurfaceTension
const HeatCapacity = YamDB.Equations.HeatCapacity
const VapourPressure = YamDB.Equations.VapourPressure
const ThermalConductivity = YamDB.Equations.ThermalConductivity
const ExpansionCoefficient = YamDB.Equations.ExpansionCoefficient
const SoundVelocity = YamDB.Equations.SoundVelocity
const VolumeChangeFusion = YamDB.Equations.VolumeChangeFusion

@testset "Density" begin
    coef = Dict("c1" => 2375.0, "c2" => 0.233, "Tref" => 933.47)
    @test Density.Assaeletal2012(400.0; coef=coef) ≈ 2499.29851 rtol=1e-14
    @test Density.Assaeletal2012(600.0; coef=coef) ≈ 2452.69851 rtol=1e-14
end

@testset "DynamicViscosity" begin
    coef = Dict("a1" => 0.408, "a2" => 343.4)
    @test DynamicViscosity.Assaeletal2012(400.0; coef=coef) ≈ 0.0028216295830908044 rtol=1e-14
    @test DynamicViscosity.Assaeletal2012(600.0; coef=coef) ≈ 0.001459934371401943 rtol=1e-14
end

@testset "Resistivity" begin
    coef = Dict("A" => 6000.0, "B" => 3.8)
    @test Resistivity.Baker1968(400.0; coef=coef) ≈ 1.5848931924611108e9 rtol=1e-14
    @test Resistivity.Baker1968(600.0; coef=coef) ≈ 15848.93192461114 rtol=1e-14
end

@testset "SurfaceTension" begin
    coef = Dict("a" => 525.0, "b" => -0.12, "c" => -273.15)
    @test SurfaceTension.IAEA2008(400.0; coef=coef) ≈ 0.5097780000000001 rtol=1e-14
    @test SurfaceTension.IAEA2008(600.0; coef=coef) ≈ 0.48577800000000004 rtol=1e-14
end

@testset "HeatCapacity" begin
    coef = Dict("cp_0" => 175.1, "a" => -0.04961, "b" => 1.985e-5, "c" => -2.099e-9, "d" => -1524000.0)
    @test HeatCapacity.Gurvich1991(400.0; coef=coef) ≈ 148.772664 rtol=1e-14
    @test HeatCapacity.Gurvich1991(600.0; coef=coef) ≈ 147.7932826666667 rtol=1e-14
end

@testset "VapourPressure" begin
    coef = Dict("a" => 33.197, "b" => -7765.6, "c" => -1.5337, "d" => 0.000864)
    @test VapourPressure.IAEA2008(600.0; coef=coef) ≈ 57627.912488892296 rtol=1e-14
    @test VapourPressure.IAEA2008(800.0; coef=coef) ≈ 1.1201923765248167e6 rtol=1e-14
end

@testset "ThermalConductivity" begin
    coef = Dict("c1" => 36.493, "c2" => 0.029185, "Tm" => 429.748)
    @test ThermalConductivity.Assaeletal2017(400.0; coef=coef) ≈ 35.62480462 rtol=1e-14
    @test ThermalConductivity.Assaeletal2017(600.0; coef=coef) ≈ 41.46180462 rtol=1e-14
end

@testset "ExpansionCoefficient" begin
    coef = Dict("a" => 1.8144, "b" => 7.016e-5, "c" => 2.8625e-7, "d" => 2.617e-10)
    @test ExpansionCoefficient.IAEA2008(400.0; coef=coef) ≈ 0.00018284399872075797 rtol=1e-14
    @test ExpansionCoefficient.IAEA2008(600.0; coef=coef) ≈ 0.00018770501062585301 rtol=1e-14
end

@testset "SoundVelocity" begin
    coef = Dict("A" => 1758.0, "B" => -0.164)
    @test SoundVelocity.Blairs2007(400.0; coef=coef) ≈ 1692.4 rtol=1e-14
    @test SoundVelocity.Blairs2007(600.0; coef=coef) ≈ 1659.6 rtol=1e-14
end

@testset "VolumeChangeFusion" begin
    coef = Dict("dV" => 25.0)
    @test VolumeChangeFusion.SchinkeSauerwald1956(; coef=coef) == 25.0

    coef = Dict("dV" => -3.5)
    @test VolumeChangeFusion.SchinkeSauerwald1956(; coef=coef) == -3.5
end
