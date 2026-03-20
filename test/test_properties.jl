# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hiroharu Sugawara
# Part of YamDB.jl
#
# Tests for Properties API (Level 1 equivalent).
# Reference values from Python yamdb.

using Test
using YamDB

@testset "SubstanceDB" begin
    db = YamDB._get_cached_db(joinpath(YamDB.DATA_DIR, "metals.yml"))
    @test has_substance(db, "Na")
    @test has_substance(db, "Ag")
    @test !has_substance(db, "Unobtainium")
    @test "Na" in list_substances(db)
    @test !isnothing(get_substance(db, "Na"))
    @test isnothing(get_substance(db, "Unobtainium"))
end

@testset "Properties — metals" begin
    na = get_from_metals("Na")
    @test na isa Properties

    @testset "Constant properties" begin
        @test na.Tm ≈ 370.87
        @test na.Tb ≈ 1156.15
        @test na.M ≈ 0.02298977
    end

    @testset "Property list and sources" begin
        props = property_list(na)
        @test "density" in props
        @test "dynamic_viscosity" in props
        @test "volume_change_fusion" in props

        sources = source_list(na, "density")
        @test "Sobolev2011" in sources
        @test default_source(na, "density") == "Ohse1985Rec"
    end

    @testset "density" begin
        @test density(na, 500.0) ≈ 898.2140876875 rtol=1e-14
        @test density(na, 500.0; source="Sobolev2011") ≈ 896.5 rtol=1e-14
    end

    @testset "dynamic_viscosity" begin
        @test dynamic_viscosity(na, 500.0) ≈ 0.00039556636118340797 rtol=1e-14
    end

    @testset "heat_capacity" begin
        @test heat_capacity(na, 500.0) ≈ 1350.2418684484446 rtol=1e-14
    end

    @testset "volume_change_fusion" begin
        @test volume_change_fusion(na) ≈ 2.6
    end

    @testset "equation_limits" begin
        tmin, tmax = equation_limits(na, "density", "Sobolev2011")
        # Sobolev2011 for Na may or may not have Tmin/Tmax
        @test tmin isa Union{Nothing,Real}
        @test tmax isa Union{Nothing,Real}
    end
end

@testset "Properties — salts" begin
    nacl = get_from_salts("NaCl")
    @test nacl isa Properties
    @test density(nacl, 1100.0) ≈ 1541.80055 rtol=1e-14
end

@testset "MixtureProperties — salts" begin
    mix = get_from_salts("CaCl2-NaCl")
    @test mix isa MixtureProperties

    comps = get_compositions_with_property(mix, "density")
    @test !isnothing(comps)
    @test "0-100" in comps
    @test "100-0" in comps
    # "range" should be excluded by default
    @test !("range" in comps)

    comps_with_range = get_compositions_with_property(mix, "density"; keep_range=true)
    @test "range" in comps_with_range

    # Access range composition
    range_props = mix.composition["range"]
    @test density(range_props, 1100.0, 30.0) ≈ 1722.44301 rtol=1e-14
end

@testset "MixtureProperties — alloys" begin
    lipb = get_from_alloys("Li-Pb")
    @test lipb isa MixtureProperties
    comps = get_compositions_with_property(lipb, "density")
    @test !isnothing(comps)
    @test length(comps) > 10
end

@testset "Janz1992" begin
    nacl_j = get_from_Janz1992("NaCl")
    @test nacl_j isa Properties
    @test density(nacl_j, 1100.0) ≈ 1542.04 rtol=1e-14
end

@testset "Error handling" begin
    @test_throws ArgumentError Properties(nothing)
    @test_throws ArgumentError MixtureProperties(nothing)
    @test_throws ArgumentError get_from_metals("Unobtainium")
end
