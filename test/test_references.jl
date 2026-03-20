# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hiroharu Sugawara
# Part of YamDB.jl

using Test
using YamDB

@testset "get_from_references" begin
    ref = get_from_references("IidaGuthrie1988")
    @test !isnothing(ref)
    @test occursin("Iida", ref)
    @test occursin("1988", ref)

    ref2 = get_from_references("Sobolev2011")
    @test !isnothing(ref2)
    @test occursin("Sobolev", ref2)

    @test isnothing(get_from_references("NonExistentKey"))
end

@testset "get_references_from_db" begin
    db_file = joinpath(YamDB.DATA_DIR, "references.yml")
    ref = get_references_from_db(db_file, "Assaeletal2012")
    @test !isnothing(ref)
    @test occursin("Assael", ref)
end

@testset "Reference keys exist for metals" begin
    # Verify that reference keys used in metals.yml exist in references.yml
    na = get_from_metals("Na")
    for prop in property_list(na)
        for src in source_list(na, prop)
            refkey = get_reference(na, prop, src)
            if refkey != src  # Only check explicit reference keys
                ref = get_from_references(refkey)
                @test !isnothing(ref)
            end
        end
    end
end
