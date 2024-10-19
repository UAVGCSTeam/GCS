import vehicle

# Call the C++ function

v1 = vehicle.Vehicle()

result = v1.getRole()
print(f"Should not work: {result}")
v1.updateRole("Awesome")
result = v1.getRole()
print(f"Should work: {result}")