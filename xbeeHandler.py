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
args = parser.parse_args()

# Determine if we should run in simulation mode
simulation_mode = args.simulate

# Try to import XBee library
try:
    from digi.xbee.devices import XBeeDevice
except ImportError:
    print("Failed to import digi.xbee.devices. Run: pip install digi-xbee")
    sys.exit(1)

# Define the data file path in a location both processes can access
DATA_FILE_PATH = "/tmp/xbee_data.json"

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
            heartbeat_data = {
                'type': 'heartbeat',
                'timestamp': time.time()
            }
            write_to_file(heartbeat_data)
            print("Sent heartbeat")
        except Exception as e:
            print(f"Error sending heartbeat: {e}")
        time.sleep(5)  # Send heartbeat every 5 seconds

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

# Connect to XBee device
xbee = None
if not simulation_mode:
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
        print("Falling back to simulation mode")
        simulation_mode = True
else:
    print("Running in simulation mode - no XBee hardware required")

# Drone address mapping
drone_name_map = {
    "0013A20012345678": "Drone1",
    "0013A20087654321": "Drone2"
    # Add your real drone XBee addresses here
}

# Main communication loop
print("Starting communication loop...")
last_sim_time = 0

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
            # Your existing XBee code for real devices
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
        print(f"Error in main loop: {e}")
        pass

    time.sleep(0.01)  # Small sleep to prevent CPU hogging
