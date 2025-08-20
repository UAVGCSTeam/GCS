#!/usr/bin/env python3
# This Python file uses the following encoding: utf-8
import sys
import time
import json
import platform
import threading
import argparse
import os

# Parse command line arguments
parser = argparse.ArgumentParser(description='XBee communication handler')
parser.add_argument('--simulate', action='store_true', help='Run in simulation mode without real XBee hardware')
parser.add_argument('--tmp-dir', help='Specify a custom directory for the temp file')
parser.add_argument('--port', help='Specify the serial port to use for XBee connection')
args = parser.parse_args()

print("Parsed arguments:", args)  # Add this line to debug the parsed arguments

# Define the data file path in a location both processes can access
if args.tmp_dir:
    # Use provided temp directory
    os.makedirs(args.tmp_dir, exist_ok=True)
    DATA_FILE_PATH = os.path.join(args.tmp_dir, "xbee_data.json")
    print(f"Using custom temp directory: {args.tmp_dir}")
elif platform.system() == "Windows":
    # Use user's temp directory as primary location (more reliable)
    temp_dir = os.environ.get('TEMP')
    if temp_dir:
        xbee_tmp_dir = os.path.join(temp_dir, 'xbee_tmp')
        os.makedirs(xbee_tmp_dir, exist_ok=True)
        DATA_FILE_PATH = os.path.join(xbee_tmp_dir, "xbee_data.json")
        print(f"Using Windows temp directory: {DATA_FILE_PATH}")
    else:
        # Fallback
        DATA_FILE_PATH = "C:/tmp/xbee_data.json"
        os.makedirs("C:/tmp", exist_ok=True)
else:
    # Unix systems
    DATA_FILE_PATH = "/tmp/xbee_data.json"

# Check if dir exists
try:
    directory = os.path.dirname(DATA_FILE_PATH)
    if not os.path.exists(directory):
        os.makedirs(directory, exist_ok=True)
        print(f"Created directory: {directory}")

    # Test file creation immediately
    with open(DATA_FILE_PATH, 'w') as f:
        f.write(json.dumps({"type": "init", "timestamp": time.time()}))
    print(f"Successfully created data file at: {DATA_FILE_PATH}")
except Exception as e:
    print(f"Error creating/writing to data file: {e}")
    print(f"Will attempt to continue...")

# Determine if we should run in simulation mode
simulation_mode = args.simulate

print("Command line arguments:", sys.argv)
if args.simulate:
    print("Running in SIMULATION mode")
else:
    print("Running in REAL HARDWARE mode")
    if args.port:
        print(f"Using port: {args.port}")
    else:
        print("No port specified, using default")

# Try to import XBee library
try:
    from digi.xbee.devices import XBeeDevice
except ImportError:
    print("Failed to import digi.xbee.devices. Run: pip install digi-xbee")
    sys.exit(1)

# Function to write data to file
def write_to_file(data):
    if isinstance(data, dict):
        data = json.dumps(data)

    try:
        with open(DATA_FILE_PATH, 'w') as f:
            f.write(data)
        print(f"Wrote data to file")
    except Exception as e:
        print(f"Error writing to file: {e}")

# Heartbeat thread to let Qt know we're alive
def heartbeat_thread():
    while True:
        try:
            status = "connected" if (xbee is not None and xbee.is_open()) else "waiting_for_connection"
            heartbeat_data = {
                'type': 'heartbeat',
                'status': status,
                'timestamp': time.time()
            }
            write_to_file(heartbeat_data)
            print(f"Sent heartbeat with status: {status}")
        except Exception as e:
            print(f"Error sending heartbeat: {e}")
        time.sleep(5)

# Start heartbeat thread
heart_thread = threading.Thread(target=heartbeat_thread, daemon=True)
heart_thread.start()

def generate_simulated_data():
    import random

    # Pick a random drone from our mapping
    address = random.choice(list(drone_name_map.keys()))
    drone_name = drone_name_map[address]

    # Generate random but realistic looking data
    lat = 34.05 + (random.random() - 0.5) * 0.01
    lon = -117.82 + (random.random() - 0.5) * 0.01
    alt = 0.05 + random.random() * 0.1
    vx = (random.random() - 0.5) * 0.2
    vy = (random.random() - 0.5) * 0.2
    vz = (random.random() - 0.5) * 0.1
    airspeed = random.random() * 0.1
    battery = 0.1 + random.random() * 0.9

    message = f"ICAO: A\n"
    message += f"Lattitude: {lat}\n"
    message += f"Longitude: {lon}\n"
    message += f"Altitude: {alt}\n"
    message += f"Velocity: [{vx}, {vy}, {vz}]\n"
    message += f"Airspeed: {airspeed:.5f}\n"
    message += f"Battery Level: {battery:.3f}"

    return address, drone_name, message

# Drone address mapping
drone_name_map = {
    "0013A20041D365C4": "testDrone", # Drone A
    "0013A20041D35C83": "testDrone2" # Drone B
    # Add your real drone XBee addresses here
    # SHOULD put fake drones for testing - also update in the manageDroneWindow, the simulation drones that get added to match
}

# Connect to XBee device
xbee = None
port = None
if not simulation_mode:
    # Determine which port to use
    if args.port:
        port = args.port  # Use the port specified by the --port argument
        print(f"Using port from command line: {port}")
    elif platform.system() == "Windows":
        port = "COM3"  # Default Windows COM port - adjust as needed
        print(f"Using default Windows port: {port}")
    else:
        port = "/dev/ttyUSB0"  # Default Linux/Mac port
        print(f"Using default Unix port: {port}")

    # Try to connect initially
    try:
        print(f"Trying to connect to XBee on port: {port}")
        xbee = XBeeDevice(port, 9600)
        xbee.open()
        print("XBee device connected successfully")
    except Exception as e:
        print(f"Failed to connect to XBee device: {e}")
        print(f"Make sure the XBee is connected and the port is correct.")
        print(f"For Windows, check Device Manager to find the correct COM port.")
        print(f"For Mac, use a port like /dev/tty.usbserial-*")
        print("Waiting for XBee connection instead of falling back to simulation mode")
        # We'll keep xbee as None and try again in the main loop
else:
    print("Running in simulation mode - no XBee hardware required")

# Main communication loop
print("Starting communication loop...")
last_sim_time = 0
last_connection_attempt = 0

while True:
    try:
        if simulation_mode:
            # Send simulated data every 2 seconds
            current_time = time.time()
            if current_time - last_sim_time >= 2:  # Every 2 seconds
                address, drone_name, message = generate_simulated_data()
                print(f"Generated simulated data for drone: {drone_name}")
                print(message)

                data = {
                    'type': 'xbee_data',
                    'drone': drone_name,
                    'address': address,
                    'message': message,
                    'timestamp': time.time()
                }
                write_to_file(data)
                print(f"Sent simulated data to file for drone: {drone_name}")
                last_sim_time = current_time
        else:
            # Real hardware mode
            current_time = time.time()

            # If we don't have a connection, try to connect periodically
            if xbee is None or not xbee.is_open():
                # Try to reconnect every 10 seconds
                if current_time - last_connection_attempt >= 10:
                    try:
                        print(f"Attempting to connect to XBee on port: {port}")
                        if xbee is None:
                            xbee = XBeeDevice(port, 9600)
                        if not xbee.is_open():
                            xbee.open()
                        print("XBee device connected successfully")
                    except Exception as e:
                        print(f"Connection attempt failed: {e}")
                        # Just wait and try again later, don't switch to simulation

                    # Update last attempt time
                    last_connection_attempt = current_time

                # Send a waiting status while not connected
                data = {
                    'type': 'status',
                    'status': 'waiting_for_connection',
                    'timestamp': time.time()
                }
                write_to_file(data)
            else:
                # If we have a connection, read data
                try:
                    xbee_message = xbee.read_data(timeout=100)
                    if xbee_message:
                        # Process real XBee message
                        sender = str(xbee_message.remote_device.get_64bit_addr())
                        message = xbee_message.data.decode('utf-8')

                        print(f"Received from {sender}: {message}")

                        # Look up which drone this belongs to based on XBee address
                        drone_name = drone_name_map.get(sender, "Unknown")

                        # Send to Qt via file
                        data = {
                            'type': 'xbee_data',
                            'drone': drone_name,
                            'address': sender,
                            'message': message,
                            'timestamp': time.time()
                        }
                        write_to_file(data)
                        print(f"Sent real data to file for drone: {drone_name}")
                except Exception as e:
                    print(f"Error reading data: {e}")
                    # Close connection if there was an error
                    try:
                        if xbee is not None and xbee.is_open():
                            xbee.close()
                            print("Closed XBee connection due to error")
                    except:
                        pass
                    # Set to None so we'll try to reconnect next iteration
                    xbee = None
    except Exception as e:
        print(f"Error in main loop: {e}")
        pass

    time.sleep(0.01)  # Small sleep to prevent CPU hogging
