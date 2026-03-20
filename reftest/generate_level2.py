#!/usr/bin/env python3
"""Generate Level 2 reference data for YamDB.jl reftest.

Level 2: All substances x all properties x all sources x temperature array.
Goal: Verify that the Julia Properties API produces identical results.

Usage:
    python3 reftest/generate_level2.py

Output:
    reftest/data/level2_metals.json
    reftest/data/level2_salts.json
    reftest/data/level2_alloys.json
    reftest/data/level2_Janz1992.json
"""

import json
import os
import sys
import traceback
import numpy as np
from yamdb.yamdb import (
    get_from_metals, get_from_salts, get_from_alloys, get_from_Janz1992,
    SubstanceDB, Properties, MixtureProperties,
)

# Temperature test points
TEMPS = [400.0, 600.0, 800.0, 1000.0, 1200.0, 1500.0, 2000.0]

# Properties that take temperature
TEMP_PROPERTIES = [
    'density', 'dynamic_viscosity', 'expansion_coefficient',
    'heat_capacity', 'resistivity', 'sound_velocity',
    'surface_tension', 'thermal_conductivity', 'vapour_pressure',
]

# Concentration test points for mixture "range" compositions
CONC_POINTS = [10.0, 30.0, 50.0, 70.0, 90.0]


def generate_substance(props, substance_name):
    """Generate reference data for a single Properties object."""
    results = []
    prop_list = props.get_property_list()

    for prop in TEMP_PROPERTIES:
        if prop not in prop_list:
            continue
        sources = props.get_source_list(prop)
        for source in sources:
            func = props.__getattribute__('_' + prop + '_func_dict')[source]
            for T in TEMPS:
                try:
                    val = func(T)
                    if np.isfinite(val):
                        results.append({
                            "property": prop,
                            "source": source,
                            "T": T,
                            "value": float(val),
                        })
                except Exception:
                    pass  # Skip invalid temperature ranges

    # volume_change_fusion (no temperature)
    if 'volume_change_fusion' in prop_list:
        sources = props.get_source_list('volume_change_fusion')
        for source in sources:
            func = props.__getattribute__('_volume_change_fusion_func_dict')[source]
            try:
                val = func()
                results.append({
                    "property": "volume_change_fusion",
                    "source": source,
                    "value": float(val),
                })
            except Exception:
                pass

    return results


def generate_mixture_range(props, substance_name):
    """Generate reference data for a MixtureProperties 'range' composition."""
    if 'range' not in props.composition:
        return []

    range_props = props.composition['range']
    results = []
    prop_list = range_props.get_property_list()

    for prop in TEMP_PROPERTIES:
        if prop not in prop_list:
            continue
        sources = range_props.get_source_list(prop)
        for source in sources:
            func = range_props.__getattribute__('_' + prop + '_func_dict')[source]
            for T in TEMPS:
                for x in CONC_POINTS:
                    try:
                        val = func(T, x)
                        if np.isfinite(val):
                            results.append({
                                "property": prop,
                                "source": source,
                                "T": T,
                                "conc": x,
                                "value": float(val),
                            })
                    except Exception:
                        pass

    return results


def generate_db(db_file, getter_func, db_name):
    """Generate reference data for an entire database file."""
    from importlib import resources as ir
    fname = os.path.join(ir.files('yamdb'), 'data', db_file)
    db = SubstanceDB(fname)
    substances = sorted(db.list_substances())

    all_data = {}
    n_total = 0

    for name in substances:
        try:
            obj = getter_func(name)
        except Exception:
            continue

        if isinstance(obj, Properties):
            results = generate_substance(obj, name)
            if results:
                all_data[name] = {"type": "pure", "results": results}
                n_total += len(results)

        elif isinstance(obj, MixtureProperties):
            entry = {"type": "mixture", "compositions": {}}

            # Test specific compositions (not "range")
            for comp_key, comp_props in sorted(obj.composition.items()):
                if comp_key == "range":
                    continue
                results = generate_substance(comp_props, f"{name}/{comp_key}")
                if results:
                    entry["compositions"][comp_key] = results
                    n_total += len(results)

            # Test "range" composition with concentration
            range_results = generate_mixture_range(obj, name)
            if range_results:
                entry["range_results"] = range_results
                n_total += len(range_results)

            if entry["compositions"] or "range_results" in entry:
                all_data[name] = entry

    print(f"  {db_name}: {len(all_data)} substances, {n_total} data points")
    return all_data


def main():
    outdir = os.path.join(os.path.dirname(__file__), "data")
    os.makedirs(outdir, exist_ok=True)

    databases = [
        ("metals.yml", get_from_metals, "metals"),
        ("salts.yml", get_from_salts, "salts"),
        ("alloys.yml", get_from_alloys, "alloys"),
        ("Janz1992_ed.yml", get_from_Janz1992, "Janz1992"),
    ]

    for db_file, getter, name in databases:
        print(f"Generating {name}...")
        try:
            data = generate_db(db_file, getter, name)
            outpath = os.path.join(outdir, f"level2_{name}.json")
            with open(outpath, "w") as f:
                json.dump(data, f)
            print(f"  Written to {outpath}")
        except Exception as e:
            print(f"  ERROR: {e}")
            traceback.print_exc()


if __name__ == "__main__":
    main()
