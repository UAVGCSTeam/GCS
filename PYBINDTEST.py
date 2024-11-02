import vehicle

v1 = vehicle.Vehicle()
v1.updateId("001")
v1.updateRole("arona")
v1.updateStatus("sleeping")
v1.printAllInfo()

v2 = vehicle.Vehicle()
v2.updateId("002")
v2.updateRole("plana")
v2.updateStatus("on")
v2.printAllInfo()

v3 = vehicle.Vehicle.getVehicle("001")
v3.printAllInfo()
v3.updateRole("shiroko")

v1.printAllInfo()
v3.printAllInfo()

v4 = vehicle.Vehicle.getVehicle("003")

v1.updatePosition(25, 25, 5)
v1.printAllInfo()

v1.updateVelocity(5, -1, 0)
v1.printAllInfo()

v1.updateOrientation(90, 90, 0)
v1.printAllInfo()   