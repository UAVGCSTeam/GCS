#!/usr/bin/env python3
import os
import sys
import subprocess
import platform
import time

# NEEDS CLEANING UP, LOTS OF ARTIFACTS FROM WHEN I TRIED TO DO SHARED MEMORY SPACE SOLUTION

# Get the directory where this script is located
script_dir = os.path.dirname(os.path.abspath(__file__))

# Define paths
venv_dir = os.path.join(script_dir, "venv")
requirements_file = os.path.join(script_dir, "requirements.txt")
xbee_handler = os.path.join(script_dir, "xbeeHandler.py")

# Path to Python in virtual environment
bin_dir = "Scripts" if platform.system() == "Windows" else "bin"
python_executable = os.path.join(venv_dir, bin_dir, "python" + (".exe" if platform.system() == "Windows" else ""))

# Create virtual environment if it doesn't exist
if not os.path.exists(venv_dir):
    print("Creating virtual environment...")
    subprocess.check_call([sys.executable, "-m", "venv", venv_dir])

# Install requirements
print("Installing required packages...")
pip_cmd = [python_executable, "-m", "pip", "install", "-r", requirements_file]
subprocess.check_call(pip_cmd)

# Run the XBee handler using the virtual environment's Python
# Use Popen instead of check_call to run in the background
print("Starting XBee handler...")
try:
    # Create log file for redirecting output
    log_path = os.path.join(script_dir, "xbee_handler.log")
    log_file = open(log_path, "w")

    # Start process in background
    process = subprocess.Popen(
        [python_executable, xbee_handler, "--simulate"],
        stdout=log_file,
        stderr=log_file,
        # Use shell=True on Windows to prevent command window from appearing
        shell=(platform.system() == "Windows")
    )

    # Wait a moment to make sure it starts successfully
    time.sleep(2)

    # Check if process is still running
    if process.poll() is None:
        print(f"XBee Python script started successfully (PID: {process.pid})")
        print(f"Output is being logged to: {log_path}")
    else:
        print("XBee handler failed to start. Check the log file for details.")
        sys.exit(1)

except Exception as e:
    print(f"Error starting XBee handler: {e}")
    sys.exit(1)

# Exit successfully - the XBee handler continues running in the background
sys.exit(0)
