#!/usr/bin/env python3
import os
import sys
import subprocess
import platform
import time
import json

# Get the directory where this script is located
script_dir = os.path.dirname(os.path.abspath(__file__))

# Use a common location that both Python and C++ can reliably find
if platform.system() == "Windows":
    config_dir = os.path.expanduser("~/AppData/Local/GCS")
elif platform.system() == "Darwin":  # macOS
    config_dir = os.path.expanduser("~/Library/Application Support/GCS")
else:  # Linux
    config_dir = os.path.expanduser("~/.config/gcs")

os.makedirs(config_dir, exist_ok=True)
config_file = os.path.join(config_dir, "xbee_config.json")

# Define paths
venv_dir = os.path.join(script_dir, "venv")
requirements_file = os.path.join(script_dir, "requirements.txt")
xbee_handler = os.path.join(script_dir, "xbeeHandler.py")
# config_file is already defined with the standardized path - don't redefine it here

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

# Load or create configuration
try:
    with open(config_file, 'r') as f:
        config = json.loads(f.read())
except (FileNotFoundError, json.JSONDecodeError):
    # Default configuration
    config = {
        "simulation_mode": True,
        "port": "COM3" if platform.system() == "Windows" else "/dev/ttyUSB0"
    }
    with open(config_file, 'w') as f:
        f.write(json.dumps(config, indent=2))
    print(f"Created default configuration file: {config_file}")

# Determine if we should run in simulation mode
sim_flag = "--simulate" if config["simulation_mode"] else ""
port_arg = f"--port={config['port']}" if not config["simulation_mode"] else ""

# Create temp directory for XBee data
if platform.system() == "Windows":
    # Use user's temp directory (more reliable)
    tmp_dir = os.path.join(os.environ.get('TEMP', ''), 'xbee_tmp')
    try:
        os.makedirs(tmp_dir, exist_ok=True)
        print(f"Using temp directory: {tmp_dir}")
    except Exception as e:
        print(f"Warning: Could not create temp directory: {e}")
        tmp_dir = None
else:
    # For Unix systems, we'll use the default /tmp
    tmp_dir = None

# Build command with appropriate arguments
xbee_args = [python_executable, xbee_handler]
if sim_flag:
    xbee_args.append(sim_flag)
if port_arg:
    xbee_args.append(port_arg)
if tmp_dir:
    xbee_args.extend(["--tmp-dir", tmp_dir])

# Run the XBee handler using the virtual environment's Python
print("Starting XBee handler...")
print(f"Mode: {'Simulation' if config['simulation_mode'] else 'Real hardware'}")
if not config["simulation_mode"]:
    print(f"Port: {config['port']}")

try:
    # Create log file for redirecting output
    log_path = os.path.join(script_dir, "xbee_handler.log")
    log_file = open(log_path, "w")

    # Start process in background
    process = subprocess.Popen(
        xbee_args,
        stdout=log_file,
        stderr=log_file,
        # Don't use shell=True as it can cause permission issues on Windows
        shell=False,
        # Make the process a new process group to avoid it being killed when the parent exits
        creationflags=subprocess.CREATE_NEW_PROCESS_GROUP if platform.system() == "Windows" else 0
    )

    # Wait a moment to make sure it starts successfully
    time.sleep(2)

    # Check if process is still running
    if process.poll() is None:
        print(f"XBee Python script started successfully (PID: {process.pid})")
        print(f"Output is being logged to: {log_path}")
        print(f"To toggle between simulation and real hardware, edit {config_file}")
    else:
        print("XBee handler failed to start. Check the log file for details.")
        sys.exit(1)
except Exception as e:
    print(f"Error starting XBee handler: {e}")
    sys.exit(1)

# Exit successfully - the XBee handler continues running in the background
sys.exit(0)
