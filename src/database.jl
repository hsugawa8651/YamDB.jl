# SPDX-License-Identifier: MIT
# Based on yamdb (Copyright 2018-2023 Tom Weier)
# Julia port Copyright (C) 2026 Hiroharu Sugawara

using SHA: sha1

#=
    SubstanceDB

Load a YAML database file and provide substance lookup.
=#
"""
    SubstanceDB

A loaded YAML database containing substance data.
Created from a YAML file path or a pre-loaded dictionary.
"""
struct SubstanceDB
    materials::Dict{String,Any}
end

function SubstanceDB(fname::AbstractString)
    materials = if endswith(fname, ".yml") || endswith(fname, ".yaml")
        YAML.load_file(fname; dicttype=Dict{String,Any})
    else
        error("Unsupported database file format: $fname")
    end
    return SubstanceDB(materials)
end

"""
    get_substance(db::SubstanceDB, name) -> Dict or Nothing

Return the substance dictionary for `name`, or `nothing` if not found.
"""
function get_substance(db::SubstanceDB, name::AbstractString)
    return get(db.materials, name, nothing)
end

"""
    has_substance(db::SubstanceDB, name) -> Bool

Check if a substance exists in the database.
"""
function has_substance(db::SubstanceDB, name::AbstractString)
    return haskey(db.materials, name)
end

"""
    has_component(db::SubstanceDB, name) -> Vector{String} or Nothing

Find mixtures containing `name` as a component (e.g., `"CaCl2"` in `"CaCl2-NaCl"`).
Returns a list of matching substance names, or `nothing` if none found.
"""
function has_component(db::SubstanceDB, name::AbstractString)
    clist = String[]
    for key in keys(db.materials)
        if name in split(key, '-')
            push!(clist, key)
        end
    end
    return isempty(clist) ? nothing : clist
end

"""
    list_substances(db::SubstanceDB) -> Vector{String}

Return a list of all substance names in the database.
"""
function list_substances(db::SubstanceDB)
    return collect(keys(db.materials))
end

# --- Database cache (keyed on file SHA1 hash) ---

const _db_cache = Dict{String,Any}()

function _file_digest(fname::AbstractString)
    return bytes2hex(open(io -> sha1(io), fname))
end

function _get_cached_db(fname::AbstractString)
    h = _file_digest(fname)
    if haskey(_db_cache, h)
        return _db_cache[h]
    end
    db = SubstanceDB(fname)
    _db_cache[h] = db
    return db
end
