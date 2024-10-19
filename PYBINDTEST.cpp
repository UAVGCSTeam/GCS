#include <pybind11/pybind11.h>

namespace py = pybind11;

// A simple function that adds two numbers
int add(int i, int j) {
    return i + j;
}

// Pybind11 module
PYBIND11_MODULE(pybindmodule, m) {
    m.def("add", &add, "A function that adds two numbers");
}