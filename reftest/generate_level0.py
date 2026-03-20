#!/usr/bin/env python3
"""Generate Level 0 reference data for YamDB.jl reftest.

Level 0: Individual equation functions with known coefficients.
Goal: bitwise exact agreement between Python and Julia.

Usage:
    python3 reftest/generate_level0.py

Output:
    reftest/data/level0_density.json
    reftest/data/level0_dynamic_viscosity.json
    ... (one file per property module)
"""

import json
import sys
import numpy as np

# Add yamdb to path
from yamdb.properties import density, dynamic_viscosity
from yamdb.properties import resistivity, surface_tension
from yamdb.properties import heat_capacity, vapour_pressure
from yamdb.properties import thermal_conductivity, expansion_coefficient
from yamdb.properties import sound_velocity, volume_change_fusion


def make_test_case(func_name, module, coef, temps, conc=None, no_temp=False):
    """Call a function and record inputs/outputs."""
    func = getattr(module, func_name)
    results = []
    if no_temp:
        val = func(coef=coef)
        results.append({"value": val})
    else:
        for T in temps:
            if conc is not None:
                val = func(T, conc, coef=coef)
            else:
                val = func(T, coef=coef)
            results.append({"T": T, "value": val})
            if conc is not None:
                results[-1]["conc"] = conc
    return {
        "function": func_name,
        "coef": coef,
        "results": results,
    }


def generate_density():
    """Generate reference data for density module."""
    cases = []
    temps = [400.0, 600.0, 800.0, 1000.0, 1200.0, 1500.0]

    # Assaeletal2012
    cases.append(make_test_case("Assaeletal2012", density,
        {"c1": 2375.0, "c2": 0.233, "Tref": 933.47}, temps))

    # Bockrisetal1962
    cases.append(make_test_case("Bockrisetal1962", density,
        {"a": 2168, "b": 0.1267, "c": 1.754e-04}, temps))

    # DoboszGancarz2018
    cases.append(make_test_case("DoboszGancarz2018", density,
        {"a1": -0.826, "a2": 8952.1}, temps))

    # Hansenetal1990
    cases.append(make_test_case("Hansenetal1990", density,
        {"a": 1.532e-03, "b": 17.465, "M": 0.1119605}, temps))

    # IAEA2008
    cases.append(make_test_case("IAEA2008", density,
        {"rho_0": 13595.0, "a": 1.0, "b": -1.8144e-04,
         "c": -7.016e-09, "d": -2.8625e-11, "e": -2.617e-14}, temps))

    # Shpilrain1985
    cases.append(make_test_case("Shpilrain1985", density,
        {"a": [0.89660679, 0.51613430, -0.18297218e+01,
               0.22016247e+01, -0.13975634e+01, 0.44866894,
               -0.57963628e-01]}, temps))

    # Sobolev2011
    cases.append(make_test_case("Sobolev2011", density,
        {"rho_s": 11441, "drhodT": -1.2795}, temps))

    # Steinberg1974
    cases.append(make_test_case("Steinberg1974", density,
        {"rho_m": 6483, "lambda": 0.82, "Tm": 903.65}, temps))

    # Linstrom1992DP
    cases.append(make_test_case("Linstrom1992DP", density,
        {"D1": 1.548, "Tmin": 1073.0, "Tmax": 1073.0}, temps))

    # Linstrom1992P1
    cases.append(make_test_case("Linstrom1992P1", density,
        {"D1": 5.035, "D2": -0.000924}, temps))

    # Linstrom1992P2
    cases.append(make_test_case("Linstrom1992P2", density,
        {"D1": 3.0183, "D2": -1.0536e-03, "D3": 3.7641e-07}, temps))

    # Janzetal1975TC (concentration-dependent)
    conc_temps = [800.0, 900.0, 1000.0, 1100.0]
    for x in [20.0, 50.0, 80.0]:
        cases.append(make_test_case("Janzetal1975TC", density,
            {"a": 2.06606, "b": -4.72915e-04, "c": 6.20063e-03,
             "d": -1.04771e-05},
            conc_temps, conc=x))

    # Janzetal1975TC2 (concentration-dependent)
    for x in [20.0, 50.0, 80.0]:
        cases.append(make_test_case("Janzetal1975TC2", density,
            {"a": 2.79673, "b": -4.71427e-04, "c": 1.12048e-02,
             "d": -2.55020e-08, "e": -5.16503e-09},
            conc_temps, conc=x))

    # Linstrom1992I1 (concentration-dependent)
    for x in [20.0, 50.0, 80.0]:
        cases.append(make_test_case("Linstrom1992I1", density,
            {"D1": 1.449, "D2": 0.01179, "component": "first"},
            [1073.0], conc=x))

    # Linstrom1992I2 (concentration-dependent)
    for x in [20.0, 50.0, 80.0]:
        cases.append(make_test_case("Linstrom1992I2", density,
            {"D1": 2.9385, "D2": -0.0027181, "D3": -2.8117e-05,
             "component": "second"},
            [1073.0], conc=x))

    # Linstrom1992I3 (concentration-dependent)
    for x in [20.0, 50.0, 80.0]:
        cases.append(make_test_case("Linstrom1992I3", density,
            {"D1": 2.319, "D2": 0.002196, "D3": -1.196e-05,
             "D4": 1.978e-07, "component": "first"},
            [1073.0], conc=x))

    # Linstrom1992I4 (concentration-dependent)
    for x in [20.0, 50.0, 80.0]:
        cases.append(make_test_case("Linstrom1992I4", density,
            {"D1": 1.403, "D2": 0.01596, "D3": -0.0002348,
             "D4": 2.106e-06, "D5": -7.598e-09, "component": "first"},
            [1073.0], conc=x))

    return cases


def generate_dynamic_viscosity():
    """Generate reference data for dynamic_viscosity module."""
    cases = []
    temps = [400.0, 600.0, 800.0, 1000.0, 1200.0, 1500.0]

    # Assaeletal2012
    cases.append(make_test_case("Assaeletal2012", dynamic_viscosity,
        {"a1": 0.408, "a2": 343.4}, temps))

    # Hirai1992
    cases.append(make_test_case("Hirai1992", dynamic_viscosity,
        {"A": 0.5266, "B": 10.91}, temps))

    # IAEA2008
    cases.append(make_test_case("IAEA2008", dynamic_viscosity,
        {"a": 0.215e-03, "b": 0, "c": 2098}, temps))

    # Janzetal1968
    cases.append(make_test_case("Janzetal1968", dynamic_viscosity,
        {"a": 41.8211, "b": -0.101156, "c": 8.49570e-05, "d": -2.42543e-08},
        temps))

    # Janzetal1968exp
    cases.append(make_test_case("Janzetal1968exp", dynamic_viscosity,
        {"A": 9.836e-02, "E": 5343.0}, temps))

    # KostalMalek2010
    cases.append(make_test_case("KostalMalek2010", dynamic_viscosity,
        {"A": -9.27, "B": 2795, "T0": 226.1}, temps))

    # Linstrom1992DP
    cases.append(make_test_case("Linstrom1992DP", dynamic_viscosity,
        {"D1": 1.2}, temps))

    # Linstrom1992E1 (no test in Python, but function exists)
    cases.append(make_test_case("Linstrom1992E1", dynamic_viscosity,
        {"D1": 0.1, "D2": 5000.0, "D3": 100.0}, temps))

    # Linstrom1992E2
    cases.append(make_test_case("Linstrom1992E2", dynamic_viscosity,
        {"D1": 0.5624, "D2": 8443.45, "D3": 332.0}, temps))

    # Linstrom1992P2
    cases.append(make_test_case("Linstrom1992P2", dynamic_viscosity,
        {"D1": 141.203, "D2": -0.403, "D3": 0.00029137}, temps))

    # Linstrom1992P3
    cases.append(make_test_case("Linstrom1992P3", dynamic_viscosity,
        {"D1": 74.249, "D2": -0.2745, "D3": 0.00034714, "D4": -1.475e-07},
        temps))

    # Linstrom1992plusE
    cases.append(make_test_case("Linstrom1992plusE", dynamic_viscosity,
        {"R": 8.314459848, "D1": 0.0840, "D2": 17994.1}, temps))

    # Ohse1985
    cases.append(make_test_case("Ohse1985", dynamic_viscosity,
        {"a": -6.4072, "b": -0.40767, "c": 432.75}, temps))

    # ToerklepOeye1982
    cases.append(make_test_case("ToerklepOeye1982", dynamic_viscosity,
        {"A": 0.17985, "B": 2470.1, "C": 0}, temps))

    # Villadaetal2021
    cases.append(make_test_case("Villadaetal2021", dynamic_viscosity,
        {"a": 27.728, "b": -0.00364, "Tref": 273.15}, temps))

    # Concentration-dependent functions
    for x in [20.0, 50.0, 80.0]:
        cases.append(make_test_case("Linstrom1992I1", dynamic_viscosity,
            {"D1": 1.033, "D2": 0.001684, "component": "first"},
            [1070.0], conc=x))

    for x in [20.0, 50.0, 80.0]:
        cases.append(make_test_case("Linstrom1992I2", dynamic_viscosity,
            {"D1": 1.203, "D2": -0.0023, "D3": 4.253e-06,
             "component": "second"},
            [1070.0], conc=x))

    for x in [20.0, 50.0, 80.0]:
        cases.append(make_test_case("Linstrom1992I3", dynamic_viscosity,
            {"D1": 1.304, "D2": -0.00263, "D3": -4.083e-05, "D4": 5.694e-07,
             "component": "first"},
            [1070.0], conc=x))

    for x in [20.0, 50.0, 80.0]:
        cases.append(make_test_case("Linstrom1992I4", dynamic_viscosity,
            {"D1": 1.304, "D2": -0.01404, "D3": 0.0003029,
             "D4": -2.709e-06, "D5": 8.148e-09, "component": "first"},
            [1070.0], conc=x))

    return cases


def generate_resistivity():
    """Generate reference data for resistivity module."""
    cases = []
    temps = [400.0, 600.0, 800.0, 1000.0, 1200.0, 1500.0]

    cases.append(make_test_case("Baker1968", resistivity,
        {"A": 6000, "B": 3.80}, temps))
    cases.append(make_test_case("constant", resistivity,
        {"value": 1.0e-06}, temps))
    cases.append(make_test_case("CusackEnderby1960", resistivity,
        {"alpha": 0.0090e-08, "beta": 6.2e-08}, temps))
    cases.append(make_test_case("Desaietal1984", resistivity,
        {"a": 40.81824, "b": 8.51402e-03, "c": -3.36074e-05, "d": 2.06737e-08}, temps))
    cases.append(make_test_case("fractionalNegativeExponent", resistivity,
        {"a": 3.76373e-06, "b": 6.55205e+12, "c": 6.50001}, temps))
    cases.append(make_test_case("IAEA2008", resistivity,
        {"a": 1, "b": 0.8896e-03, "c": 1.0075e-06, "d": -1.05e-10,
         "e": 2.702e-13, "f": 1.199e-15, "rho_e0": 0.9407e-06}, temps))
    cases.append(make_test_case("Janzetal1968", resistivity,
        {"a": -6.1952, "b": 12.6232e-03, "c": -5.0591e-06}, temps))
    cases.append(make_test_case("Janz1967exp", resistivity,
        {"A": 43.70816, "E": 4687.94e-03}, temps))
    cases.append(make_test_case("Linstrom1992plusE", resistivity,
        {"D1": 10.113, "D2": -5903.72}, temps))
    cases.append(make_test_case("Linstrom1992DP", resistivity,
        {"D1": 2.8}, temps))
    cases.append(make_test_case("Linstrom1992E2", resistivity,
        {"D1": 0.1, "D2": 5000.0, "D3": 100.0}, temps))
    cases.append(make_test_case("Linstrom1992P1", resistivity,
        {"D1": -3.80334, "D2": 7.59545e-03}, temps))
    cases.append(make_test_case("Linstrom1992P2", resistivity,
        {"D1": -1.0423, "D2": 0.0037731, "D3": -1.7211e-06}, temps))
    cases.append(make_test_case("Linstrom1992P3", resistivity,
        {"D1": -2.525, "D2": 0.0060275, "D3": -3.9683e-06, "D4": 7.999e-10}, temps))
    cases.append(make_test_case("Linstrom1992P4", resistivity,
        {"D1": 1.0, "D2": 0.001, "D3": -1e-06, "D4": 1e-09, "D5": -1e-12}, temps))
    cases.append(make_test_case("Massetetal2006", resistivity,
        {"A": 8.895, "E": -872.6}, temps))
    cases.append(make_test_case("SalyulevPotapov2015", resistivity,
        {"a": 0.26654, "b": 381.67, "c": -3.4064e+05, "d": -5.7406e+08}, temps))
    cases.append(make_test_case("Sobolev2011", resistivity,
        {"a": 3.06821e-08, "b": 4.77161e-10, "c": 4.84378e-13}, temps))
    cases.append(make_test_case("Zinkle1998", resistivity,
        {"a": -64.9, "b": 1.064, "c": -1.035e-03, "d": 5.33e-07, "e": -9.23e-12}, temps))

    # Ohse1985 piecewise
    ohse_coef = {"range": [
        {"a": 1.353, "b": 1.051, "c": 0.485, "d": -0.498, "Tmin": 312.6, "Tmax": 611.7},
        {"a": 1.689, "b": 1.207, "c": 0.049, "d": 4.138, "Tmin": 611.7, "Tmax": 1087.7},
        {"a": 2.057, "b": 0.880, "c": 3.153, "d": -0.531, "Tmin": 1087.7, "Tmax": 1500},
    ]}
    ohse_temps = [400.0, 600.0, 800.0, 1000.0, 1200.0, 1400.0]
    cases.append(make_test_case("Ohse1985", resistivity, ohse_coef, ohse_temps))

    # Concentration-dependent
    for x in [20.0, 50.0, 80.0]:
        cases.append(make_test_case("Linstrom1992I1", resistivity,
            {"D1": 1.495, "D2": 0.01277, "component": "second"}, [1273.0], conc=x))
    for x in [20.0, 50.0, 80.0]:
        cases.append(make_test_case("Linstrom1992I2", resistivity,
            {"D1": 5.85, "D2": -0.04785, "D3": -0.001579, "component": "second"},
            [1233.2], conc=x))
    for x in [20.0, 50.0, 80.0]:
        cases.append(make_test_case("Linstrom1992I3", resistivity,
            {"D1": 1.6794, "D2": -0.034436, "D3": 0.00041854, "D4": -7.445e-07,
             "component": "second"}, [1073.0], conc=x))
    for x in [20.0, 50.0, 80.0]:
        cases.append(make_test_case("Linstrom1992I4", resistivity,
            {"D1": -0.0008485, "D2": 0.001286, "D3": -0.000651, "D4": 0.0001342,
             "D5": -8.863e-06, "component": "second"}, [405.0], conc=x))

    return cases


def generate_surface_tension():
    """Generate reference data for surface_tension module."""
    cases = []
    temps = [400.0, 600.0, 800.0, 1000.0, 1200.0, 1500.0]

    cases.append(make_test_case("IAEA2008", surface_tension,
        {"a": 525, "b": -0.12, "c": -273.15}, temps))
    cases.append(make_test_case("Sobolev2011", surface_tension,
        {"a": 570.7, "b": -0.1312}, temps))
    cases.append(make_test_case("Linstrom1992DP", surface_tension,
        {"D1": 100.0}, temps))
    cases.append(make_test_case("Linstrom1992P1", surface_tension,
        {"D1": 150.0, "D2": -0.05}, temps))
    cases.append(make_test_case("Linstrom1992P2", surface_tension,
        {"D1": 200.0, "D2": -0.1, "D3": 1e-05}, temps))

    for x in [20.0, 50.0, 80.0]:
        cases.append(make_test_case("Linstrom1992I1", surface_tension,
            {"D1": 100.0, "D2": 0.5, "component": "first"}, [1073.0], conc=x))
    for x in [20.0, 50.0, 80.0]:
        cases.append(make_test_case("Linstrom1992I2", surface_tension,
            {"D1": 100.0, "D2": 0.5, "D3": -0.01, "component": "first"},
            [1073.0], conc=x))
    for x in [20.0, 50.0, 80.0]:
        cases.append(make_test_case("Linstrom1992I3", surface_tension,
            {"D1": 100.0, "D2": 0.5, "D3": -0.01, "D4": 0.0001,
             "component": "first"}, [1073.0], conc=x))
    for x in [20.0, 50.0, 80.0]:
        cases.append(make_test_case("Linstrom1992I4", surface_tension,
            {"D1": 100.0, "D2": 0.5, "D3": -0.01, "D4": 0.0001, "D5": -1e-06,
             "component": "first"}, [1073.0], conc=x))

    return cases


def generate_heat_capacity():
    """Generate reference data for heat_capacity module."""
    cases = []
    temps = [400.0, 600.0, 800.0, 1000.0, 1200.0, 1500.0]

    cases.append(make_test_case("Gurvich1991", heat_capacity,
        {"cp_0": 175.1, "a": -4.961e-02, "b": 1.985e-05, "c": -2.099e-09,
         "d": -1.524e+06}, temps))
    cases.append(make_test_case("IAEA2008", heat_capacity,
        {"cp_0": 0.1508, "a": -6.630e-05, "b": 6.4185e-08, "c": 0.8049}, temps))
    cases.append(make_test_case("IidaGuthrie1988", heat_capacity,
        {"cp_mol": 32.64, "M": 24.305e-03}, temps))
    cases.append(make_test_case("IidaGuthrie2015", heat_capacity,
        {"cp_0": 19.04, "a": 10.38e-03, "b": -3.97e-06, "c": 20.75e+05,
         "M": 208.9804e-03}, temps))
    cases.append(make_test_case("Imbeni1998", heat_capacity,
        {"cp_0": 118.2, "a": 5.934e-03, "b": 7.183e+06}, temps))
    cases.append(make_test_case("Ohse1985", heat_capacity,
        {"C1": 36.519, "C2": -2.1139e-02, "C3": 1.5891e-05, "M": 132.90543e-03}, temps))
    cases.append(make_test_case("Sobolev2011", heat_capacity,
        {"cp_0": 176.2, "a": -4.923e-02, "b": 1.544e-05, "c": -1.524e+06}, temps))

    return cases


def generate_vapour_pressure():
    """Generate reference data for vapour_pressure module."""
    cases = []
    temps = [600.0, 800.0, 1000.0, 1200.0, 1500.0]

    cases.append(make_test_case("IAEA2008", vapour_pressure,
        {"a": 33.197, "b": -7765.6, "c": -1.5337, "d": 0.864e-03}, temps))
    cases.append(make_test_case("IidaGuthrie2015", vapour_pressure,
        {"A": 12.79, "B": -7550, "C": -1.41, "unit": "mmHg"}, temps))
    cases.append(make_test_case("Kelley1935", vapour_pressure,
        {"A": 46700.0, "B": 16.1, "C": 81.15}, temps))
    cases.append(make_test_case("Ohse1985", vapour_pressure,
        {"A": 13.0719, "B": -18880.659, "C": -0.4942}, temps))
    cases.append(make_test_case("Sobolev2011", vapour_pressure,
        {"a": 5.76e+09, "b": -22131}, temps))
    cases.append(make_test_case("Villadaetal2021", vapour_pressure,
        {"a": 3.1e-08, "b": 0.0214, "Tref": 273.15}, temps))
    cases.append(make_test_case("Wangetal2021", vapour_pressure,
        {"a": -4.0966, "b": 0.030355, "c": -7.909e-05, "d": 7.1320e-08,
         "Tref": 273.15}, temps))

    return cases


def generate_thermal_conductivity():
    """Generate reference data for thermal_conductivity module."""
    cases = []
    temps = [400.0, 600.0, 800.0, 1000.0, 1200.0, 1500.0]

    cases.append(make_test_case("Assaeletal2017", thermal_conductivity,
        {"c1": 36.493, "c2": 0.029185, "Tm": 429.748}, temps))
    cases.append(make_test_case("Chliatzouetal2018", thermal_conductivity,
        {"c0": 208.8, "c1": -0.115, "Tm": 919.15}, temps))
    cases.append(make_test_case("IAEA2008", thermal_conductivity,
        {"a": 8.178, "b": 1.36e-02, "c": -6.378e-06}, temps))
    cases.append(make_test_case("Sobolev2011", thermal_conductivity,
        {"a": 75.5685, "b": -0.0587519, "c": 1.40155e-05}, temps))
    cases.append(make_test_case("SquareRoot", thermal_conductivity,
        {"a": -30.6834, "b": -0.07775, "c": 5.27445}, temps))
    cases.append(make_test_case("Touloukian1970b", thermal_conductivity,
        {"a": 19.7907, "b": 0.0631304}, temps))

    return cases


def generate_expansion_coefficient():
    """Generate reference data for expansion_coefficient module."""
    cases = []
    temps = [400.0, 600.0, 800.0, 1000.0, 1200.0, 1500.0]

    cases.append(make_test_case("IAEA2008", expansion_coefficient,
        {"a": 1.8144, "b": 7.016e-05, "c": 2.8625e-07, "d": 2.617e-10}, temps))
    cases.append(make_test_case("OECDNEA2015", expansion_coefficient,
        {"a": 8942}, temps))
    cases.append(make_test_case("Sobolev2011", expansion_coefficient,
        {"rho_s": 4072.0, "drhodT": -1.3}, temps))
    cases.append(make_test_case("Steinberg1974", expansion_coefficient,
        {"rho_m": 17400, "lambda": 1.45, "Tm": 1336.15}, temps))

    return cases


def generate_sound_velocity():
    """Generate reference data for sound_velocity module."""
    cases = []
    temps = [400.0, 600.0, 800.0, 1000.0, 1200.0, 1500.0]

    cases.append(make_test_case("Blairs2007", sound_velocity,
        {"A": 1758, "B": -0.164}, temps))
    cases.append(make_test_case("Blairs2007cubic", sound_velocity,
        {"A": 1720, "B": -9.199e-02, "C": -4.628e-05}, temps))
    cases.append(make_test_case("IAEA2008", sound_velocity,
        {"a": 1460, "b": -7765.6, "c": -0.4671}, temps))
    cases.append(make_test_case("linearExperimental", sound_velocity,
        {"Um": 1620, "m_dUdT": 0.21, "Tm": 544.10}, temps))

    return cases


def generate_volume_change_fusion():
    """Generate reference data for volume_change_fusion module."""
    cases = []
    cases.append(make_test_case("SchinkeSauerwald1956", volume_change_fusion,
        {"dV": 25.0}, [], no_temp=True))
    cases.append(make_test_case("SchinkeSauerwald1956", volume_change_fusion,
        {"dV": -3.5}, [], no_temp=True))
    return cases


def write_module(outdir, name, generate_func):
    """Generate and write reference data for a module."""
    data = generate_func()
    outpath = os.path.join(outdir, f"level0_{name}.json")
    with open(outpath, "w") as f:
        json.dump(data, f, indent=2)
    n_results = sum(len(c["results"]) for c in data)
    print(f"Generated {outpath} ({len(data)} cases, {n_results} data points)")


if __name__ == "__main__":
    import os
    outdir = os.path.join(os.path.dirname(__file__), "data")
    os.makedirs(outdir, exist_ok=True)

    modules = [
        ("density", generate_density),
        ("dynamic_viscosity", generate_dynamic_viscosity),
        ("resistivity", generate_resistivity),
        ("surface_tension", generate_surface_tension),
        ("heat_capacity", generate_heat_capacity),
        ("vapour_pressure", generate_vapour_pressure),
        ("thermal_conductivity", generate_thermal_conductivity),
        ("expansion_coefficient", generate_expansion_coefficient),
        ("sound_velocity", generate_sound_velocity),
        ("volume_change_fusion", generate_volume_change_fusion),
    ]
    for name, func in modules:
        write_module(outdir, name, func)
