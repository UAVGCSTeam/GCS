#!/usr/bin/env python3
import os
import sys
import subprocess
import platform

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
print("Starting XBee handler...")
subprocess.check_call([python_executable, xbee_handler])
