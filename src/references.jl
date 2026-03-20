# SPDX-License-Identifier: MIT
# Based on yamdb (Copyright 2018-2023 Tom Weier)
# Julia port Copyright (C) 2026 Hiroharu Sugawara

"""
    load_yaml_references(db_file) -> Dict{String, Any}

Load a YAML references file and return it as a dictionary.
"""
function load_yaml_references(db_file::AbstractString)
    return YAML.load_file(db_file; dicttype=Dict{String,Any})
end

"""
    get_references_from_db(db_file, key) -> String or Nothing

Look up a citation key in a YAML references file. Returns `nothing` if not found.
The file is cached by SHA1 hash.
"""
function get_references_from_db(db_file::AbstractString, key::AbstractString)
    h = _file_digest(db_file)
    db = if haskey(_db_cache, h)
        _db_cache[h]
    else
        refs = load_yaml_references(db_file)
        _db_cache[h] = refs
        refs
    end
    return get(db, key, nothing)
end

function _get_references_from_included_db(db_file::AbstractString, key::AbstractString)
    fname = joinpath(DATA_DIR, db_file)
    return get_references_from_db(fname, key)
end

"""
    get_from_references(key) -> String or Nothing

Look up a citation key in the bundled `references.yml` file.
Returns the reference string, or `nothing` if the key is not found.
"""
function get_from_references(key::AbstractString)
    return _get_references_from_included_db("references.yml", key)
end
