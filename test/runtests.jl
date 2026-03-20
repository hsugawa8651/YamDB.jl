# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hiroharu Sugawara

using Test
using YamDB

@testset "YamDB.jl" begin
    @testset "Module loading" begin
        @test isdefined(YamDB, :AbstractProperties)
        @test isdefined(YamDB, :EquationPatterns)
        @test isdir(YamDB.DATA_DIR)
    end
    @testset "Equation Patterns" begin
        include("test_patterns.jl")
    end
    @testset "Equation Functions" begin
        include("test_equations.jl")
    end
    @testset "Properties API" begin
        include("test_properties.jl")
    end
    @testset "References" begin
        include("test_references.jl")
    end
end
