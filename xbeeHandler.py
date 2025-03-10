# This Python file uses the following encoding: utf-8
import sys
import time
import json
import platform
import threading

# Platform-specific shared memory implementation
if platform.system() == "Windows":
    try:
        import mmap
        import tempfile
        import os

        # Windows shared memory implementation
        class SharedMemory:
            def __init__(self, name, flags, size):
                self.name = name
                self.size = size
                self.file_path = os.path.join(tempfile.gettempdir(), name)
                print(f"Creating Windows shared memory at: {self.file_path}")
                self.file = open(self.file_path, 'wb+')
                self.file.write(b'\0' * size)
                self.file.flush()
                self.mmap = mmap.mmap(self.file.fileno(), size)
                print(f"Windows shared memory created successfully")

            def write(self, data):
                self.mmap.seek(0)
                self.mmap.write(data)
                self.mmap.flush()
    except ImportError as e:
        print(f"Error importing Windows modules: {e}")
        sys.exit(1)
else:
    try:
        import sysv_ipc
    except ImportError:
        print("On Unix/macOS, you need to run: pip install sysv_ipc")
        sys.exit(1)

# Try to import XBee library
try:
    from digi.xbee.devices import XBeeDevice
except ImportError:
    print("Failed to import digi.xbee.devices. Run: pip install digi-xbee")
    sys.exit(1)

# Shared memory name - must match what's used in Qt
SHARED_MEMORY_NAME = "XbeeSharedMemory"
SHARED_MEMORY_SIZE = 4096

# Function to get the same key that Qt uses for shared memory (for Unix systems)
def get_qt_shared_memory_key(name):
    hash_value = 0
    for char in name:
        hash_value = (hash_value * 31 + ord(char)) & 0x7FFFFFFF
    return hash_value

# Create platform-specific shared memory
if platform.system() == "Windows":
    try:
        shared_memory = SharedMemory(SHARED_MEMORY_NAME, 0, SHARED_MEMORY_SIZE)
    except Exception as e:
        print(f"Failed to create Windows shared memory: {e}")
        sys.exit(1)
else:
    try:
        memory_key = get_qt_shared_memory_key(SHARED_MEMORY_NAME)
        shared_memory = sysv_ipc.SharedMemory(memory_key, sysv_ipc.IPC_CREAT, size=SHARED_MEMORY_SIZE)
        print(f"Created shared memory with key: {memory_key} (hex: 0x{memory_key:X})")
    except Exception as e:
        print(f"Failed to create shared memory: {e}")
        sys.exit(1)

# Function to write to shared memory
def write_to_shared_memory(data):
    if isinstance(data, dict):
        data = json.dumps(data)
    if isinstance(data, str):
        data = data.encode('utf-8')
        # Ensure it's padded to avoid partial reads
        if len(data) < SHARED_MEMORY_SIZE:
            data = data + b'\0' * (SHARED_MEMORY_SIZE - len(data))
    try:
        shared_memory.write(data)
    except Exception as e:
        print(f"Error writing to shared memory: {e}")

# Heartbeat thread to let Qt know we're alive
def heartbeat_thread():
    while True:
        try:
            heartbeat_data = {
                'type': 'heartbeat',
                'timestamp': time.time()
            }
            write_to_shared_memory(heartbeat_data)
            print("Sent heartbeat")
        except Exception as e:
            print(f"Error sending heartbeat: {e}")
        time.sleep(5)  # Send heartbeat every 5 seconds

# Start heartbeat thread
heart_thread = threading.Thread(target=heartbeat_thread, daemon=True)
heart_thread.start()



# HERE HERE HERE
# Connect to XBee device
try:
    # Use different serial port naming based on platform
    if platform.system() == "Windows":
        port = "COM3"  # Default Windows COM port - adjust as needed
    else:
        port = "/dev/ttyUSB0"  # Default Linux/Mac port

    print(f"Trying to connect to XBee on port: {port}")
    xbee = XBeeDevice(port, 9600)
    xbee.open()
    print("XBee device connected successfully")
except Exception as e:
    print(f"Failed to connect to XBee device: {e}")
    print(f"Make sure the XBee is connected and the port is correct.")
    print(f"For Windows, check Device Manager to find the correct COM port.")
    print(f"For Mac, use a port like /dev/tty.usbserial-*")
    sys.exit(1)  # Exit with error
# HERE HERE HERE



# Drone address mapping
drone_name_map = {
    "0013A20012345678": "Drone1",
    "0013A20087654321": "Drone2"
    # Add your real drone XBee addresses here
}

# Main communication loop
print("Starting communication loop...")

while True:
    try:
        # Check for incoming XBee messages
        xbee_message = xbee.read_data(timeout=100)
        if xbee_message:
            sender = str(xbee_message.remote_device.get_64bit_addr())
            message = xbee_message.data.decode('utf-8')

            print(f"Received from {sender}: {message}")

            # Look up which drone this belongs to based on XBee address
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
            print(f"Sent data to shared memory for drone: {drone_name}")
    except Exception as e:
        print(f"Error in main loop: {e}")

    time.sleep(0.01)  # Small sleep to prevent CPU hogging
