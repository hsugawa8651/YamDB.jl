# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hiroharu Sugawara

using Documenter
using YamDB

makedocs(;
    sitename="YamDB.jl",
    modules=[YamDB],
    pages=[
        "Home" => "index.md",
        "Usage Guide" => "usage.md",
        "Equation Patterns" => "equations.md",
        "API Reference" => "api.md",
        "Reftest" => "reftest.md",
    ],
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", nothing) == "true",
    ),
    remotes=nothing,
)

deploydocs(;
    repo="github.com/hsugawa8651/YamDB.jl",
)
