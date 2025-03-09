# This Python file uses the following encoding: utf-8
import sys
import time
import json
import sysv_ipc
from digi.xbee.devices import XBeeDevice

# Shared memory name - must match what's used in Qt
SHARED_MEMORY_NAME = "XbeeSharedMemory"
SHARED_MEMORY_SIZE = 4096

# Function to get the same key that Qt uses for shared memory
def get_qt_shared_memory_key(name):
    # This is a simplified version - you may need to adjust based on how Qt calculates keys
    # idk this is just what I found!! IDK HOW THIS WORKS
    hash_value = 0
    for char in name:
        hash_value = (hash_value * 31 + ord(char)) & 0x7FFFFFFF
    return hash_value

# Create the shared memory segment that Qt will attach to
memory_key = get_qt_shared_memory_key(SHARED_MEMORY_NAME)
try:
    # Create the shared memory - the Qt app will attach to this
    shared_memory = sysv_ipc.SharedMemory(memory_key, sysv_ipc.IPC_CREAT, size=SHARED_MEMORY_SIZE)
    print(f"Created shared memory with key: {memory_key}")
except Exception as e:
    print(f"Failed to create shared memory: {e}")
    sys.exit(1)







# Connect to XBee device
# CONNECT HERE HERE HERE IP HERE
try:
    xbee = XBeeDevice("/dev/ttyUSB0", 9600)
    xbee.open()
    print("XBee device connected")
except Exception as e:
    print(f"Failed to connect to XBee device: {e}")
    sys.exit(1)
# HERE HERE HERE HERE










# Function to write to shared memory
def write_to_shared_memory(data):
    if isinstance(data, dict):
        data = json.dumps(data)
    if isinstance(data, str):
        data = data.encode('utf-8')
    try:
        shared_memory.write(data)
    except Exception as e:
        print(f"Error writing to shared memory: {e}")

# Main XBee communication loop
print("Listening for XBee messages...")
while True:
    try:
        # Check for incoming XBee messages
        xbee_message = xbee.read_data(timeout=100)
        if xbee_message:
            sender = str(xbee_message.remote_device.get_64bit_addr())
            message = xbee_message.data.decode('utf-8')

            print(f"Received from {sender}: {message}")

            # Look up which drone this belongs to based on XBee address
            # For now using a placeholder mapping
            # implement lookup based on drone IP
            # So we can name the drones n shit
            drone_name_map = {
                "0013A20012345678": "Drone1",
                "0013A20087654321": "Drone2"
                # Add your real drone XBee addresses here
            }

            drone_name = drone_name_map.get(sender, "Unknown")

            # Send to Qt via shared memory
            data = {
                'type': 'xbee_data',
                'drone': drone_name,
                'address': sender,
                'message': message,
                'timestamp': time.time()
            }
            write_to_shared_memory(data)

    except Exception as e:
        print(f"Error in main loop: {e}")

    time.sleep(0.01)  # Small sleep to prevent CPU hogging
