from setuptools import setup, Extension
import pybind11

ext_modules = [
    Extension(
        'vehicle',  # Name of the module
        ['Vehicle.cpp'],  # Source file(s)
        include_dirs=[pybind11.get_include()],  # Pybind11 include path
        language='c++',
    ),
]

setup(
    name='vehicle',
    ext_modules=ext_modules,
)

# python PYBINDSETUP.py build_ext --inplace
