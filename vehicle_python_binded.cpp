#include <pybind11/pybind11.h>
#include "vehicle.h"

namespace py = pybind11;

//create python libarry named gcsdrone_interface
// wow python has some horrible naming conventions yall code in this?
// m is the py::module_ that actually creates the binding; source: pybind11 docs
PYBIND11_MODULE(gcsdrone_interface, m)
{
    py::class_<Vehicle>(m, "Vehicle")
    .def(py::init<>()) // what the heck is going on here
          // removed getVehicle, because Xbee shouldn't need the actual object
        .def("getRole", &Vehicle::getRole)
        .def("updateRole", &Vehicle::updateRole)
        .def("getStatus", &Vehicle::getStatus)
        .def("updateStatus", &Vehicle::updateStatus)
        .def("getBatteryLevel", &Vehicle::getBatteryLevel)
        .def("updateBatteryLevel", &Vehicle::updateBatteryLevel)
        .def("getPosition", // what is this
             [](Vehicle &v) { return py::make_tuple(v.position[0], v.position[1], v.position[2]); })
        .def("updatePosition", &Vehicle::updatePosition)
        .def("getVelocity",
             [](Vehicle &v) { return py::make_tuple(v.velocity[0], v.velocity[1], v.velocity[2]); })
        .def("updateVelocity", &Vehicle::updateVelocity)
        .def("getID", &::Vehicle::getID)
        .def("updateID", &Vehicle::updateID)
        .def("getOrientation",
             [](Vehicle &v) {
                 return py::make_tuple(v.orientation[0], v.orientation[1], v.orientation[2]);
             })
        .def("updateOrientation", &Vehicle::updateOrientation)
        .def("printAllDroneInfo", &Vehicle::printAllDroneInfo);
}
