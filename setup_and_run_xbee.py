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
print(f"Loading configuration from: {config_file}")
try:
    with open(config_file, 'r') as f:
        config_content = f.read().strip()
        print(f"Raw config content: {config_content}")
        config = json.loads(config_content)
        print(f"Parsed config: {config}")
except (FileNotFoundError, json.JSONDecodeError) as e:
    print(f"Error loading config: {e}")
    # Default configuration
    config = {
        "simulation_mode": True,
        "port": "COM3" if platform.system() == "Windows" else "/dev/ttyUSB0"
    }
    with open(config_file, 'w') as f:
        f.write(json.dumps(config, indent=2))
    print(f"Created default configuration file: {config_file}")

# Build command with appropriate arguments
xbee_args = [python_executable, xbee_handler]

# Only add --simulate flag if simulation_mode is True
if config.get("simulation_mode", True):
    xbee_args.append("--simulate")
    print("Adding --simulate flag (simulation mode is enabled)")
else:
    print("Not adding --simulate flag (simulation mode is disabled)")

    # Only add port if we're not in simulation mode
    if "port" in config:
        port_arg = f"--port={config['port']}"
        xbee_args.append(port_arg)
        print(f"Adding port argument: {port_arg}")

# Create temp directory for XBee data
if platform.system() == "Windows":
    # Use user's temp directory (more reliable)
    tmp_dir = os.path.join(os.environ.get('TEMP', ''), 'xbee_tmp')
    try:
        os.makedirs(tmp_dir, exist_ok=True)
        print(f"Using temp directory: {tmp_dir}")
    except Exception as e:
        print(f"Warning: Could not create temp directory: {e}")
        # Even on error, try to use this path
        tmp_dir = os.path.join(os.environ.get('TEMP', ''), 'xbee_tmp')
else:
    # For Unix systems, we'll use the default /tmp
    tmp_dir = None

# Add tmp_dir if it exists
if tmp_dir:
    xbee_args.extend(["--tmp-dir", tmp_dir])
    print(f"Adding tmp-dir argument: {tmp_dir}")

# Print the final command
print("Full command:", " ".join(xbee_args))

# Run the XBee handler using the virtual environment's Python
print("\nStarting XBee handler...")
print(f"Mode: {'Simulation' if config.get('simulation_mode', True) else 'Real hardware'}")
if not config.get("simulation_mode", True) and "port" in config:
    print(f"Port: {config['port']}")

try:
    # Create log file for redirecting output
    log_path = os.path.join(script_dir, "xbee_handler.log")

    # For initial debugging, let's not redirect output so we can see what's happening
    debug_mode = True  # Set to False when everything is working

    if debug_mode:
        # Run process without redirecting output
        process = subprocess.Popen(
            xbee_args,
            # Don't use shell=True as it can cause permission issues on Windows
            shell=False,
            # Make the process a new process group to avoid it being killed when the parent exits
            creationflags=subprocess.CREATE_NEW_PROCESS_GROUP if platform.system() == "Windows" else 0
        )
    else:
        # Normal operation with logging
        log_file = open(log_path, "w")
        process = subprocess.Popen(
            xbee_args,
            stdout=log_file,
            stderr=log_file,
            shell=False,
            creationflags=subprocess.CREATE_NEW_PROCESS_GROUP if platform.system() == "Windows" else 0
        )

    # Wait a moment to make sure it starts successfully
    time.sleep(2)

    # Check if process is still running
    if process.poll() is None:
        print(f"XBee Python script started successfully (PID: {process.pid})")
        if not debug_mode:
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
