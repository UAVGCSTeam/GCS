import vehicle

# This Python file uses the following encoding: utf-8
from digi.xbee.devices import XBeeDevice, RemoteXBeeDevice #, XBee64BitAddress
from digi.xbee.exception import XBeeException
from digi.xbee.models.address import XBee64BitAddress

PORT = "COM4" # need to change when we get new xbees (COM3: A)
    # Replace with the baud rate of your sender module.
BAUD_RATE = 9600

xbee_device = XBeeDevice(PORT, BAUD_RATE)

# this will hold the xbee remote device to grab to send messages to
remote_xbee_devices = []
# this will hold the id or name of the drone whose position matches that of the xbee device in the previous array... maybe
remote_drone_name = []
remote_devices_count = 0

# we technically do not need rn
def initialize_xbee(port, baud_rate):
    global xbee_device
    if xbee_device is None:
        xbee_device = XBeeDevice(port, baud_rate)
        try:
            xbee_device.open()
        except Exception as e:
            xbee_device = None
            print(f"failed to open: {str(e)}")
            raise
    else:
        print("Xbee device is already initialized")


def connect_gcs_xbee():
    global xbee_device
    print("trying to connect xbee...")
    try:
        # if device is already open, print message for user and close device
        if xbee_device.is_open():
            print("Already open")
            xbee_device.close()

        # try opening device, and if successful, print results for user
        xbee_device.open()
        print("Successfully opened")
        xbee_device.add_data_received_callback(data_receive_callback)
    except XBeeException as e:
        print("myDevice.open() >> Error")
        print(e)
        exit(1)  # close program
    except Exception as e:
        print("myDevice.close() >> Error")
        print(e)

def close_xbee_port():
    global xbee_device
    xbee_device.close()

def send_command_to_xbee(position, msg):
    global xbee_device, remote_xbee_devices
    try:
        msg = "hi"
        data_to_send = msg.encode()
        xbee_device.send_data_async(remote_xbee_devices[position], data_to_send)
    except XBeeException as e:
        print("Error")
        print(e)
        exit(1)

def create_remote_xbee_device(address, drone_id):
    global xbee_device, remote_xbee_devices, remote_drone_name, remote_devices_count
    temp_address = XBee64BitAddress.from_hex_string(address)
    temp = RemoteXBeeDevice(xbee_device, temp_address)
    remote_xbee_devices.append(temp)
    remote_drone_name.append(drone_id)
    remote_devices_count += 1

def data_receive_callback(xbee_message):
    data = xbee_message.data.decode("utf-8")
    lines = data.split('\n')
    # print(lines)
    print(lines)
    v1.updatePosition(float(lines[1]), float(lines[2]), float(lines[3]))
    v1.printAllInfo()
    # parsed_data = {}
    # for line in lines:
    #     if line.strip():  # Check if the line is not empty
    #         try:
    #             key, value = line.split(': ', 1)
    #             parsed_data[key.strip()] = value.strip()
    #         except ValueError:
    #             print(f"Skipping malformed line: {line}")
    # # vehicle.Vehicle.getVehicle(data[0:1])
  # idk what the python to c++ looks like but after getting the vehicle we need to update its parameters using the dictionary we have

v1 = vehicle.Vehicle()
def main():
    connect_gcs_xbee()
    while(True):
        pass

main()