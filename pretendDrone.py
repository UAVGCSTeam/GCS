# from serial import Serial
# import dronekit as dk     
# import time 
# from time import strftime
# from pymavlink import mavutil
from datetime import datetime
from digi.xbee.devices import XBeeDevice
from digi.xbee.devices import RemoteXBeeDevice
from digi.xbee.models.address import XBee64BitAddress
import serial
import time
# import matplotlib.pyplot as plt

# =========== CONFIGURATION ===========
# PORT = "/dev/tty.usbserial-AB0OPBOT"
PORT = "COM8"  # matched with MAC: 0013A200422F2FDF
BAUDRATE = 9600

# open serial port on wired XBee 
localXbee = XBeeDevice(PORT, BAUDRATE) # connect the device
localXbee.open()

# Option 1. Setup remote Xbee drone with MAC address of the current plugged in XBee (same as localXbee)
# remote_xbee_address = localXbee.get_64bit_addr()
# droneXbee = RemoteXBeeDevice(localXbee, remote_xbee_address)

# Option 2. OR get the MAC address of a remote XBee (found on the underside of the smaller chip on the XBee board)
# remote_xbee_address = "0013A200422F2FDF" z
# remote_xbee_address = "13A200422F2FDF" # Xbee_A, COM3?
remote_xbee_address = "13A20041D365C4" #Xbee_C, COM6?
# remote_xbee_address = "13A200420396EE" #GCSXbee, COM7?

droneXbee = RemoteXBeeDevice(localXbee, XBee64BitAddress.from_hex_string(remote_xbee_address))

print("XBee open")

def data_receive_callback(xbee_message):
    # Callback function when data is received
    print(f"Received data: {xbee_message.data.decode()}")
    # localXbee.send_data_async(droneXbee, "hi drone")

def send_UAV_data_Xbee(ICAO, pos_lat, pos_lon, pos_alt_rel,velocity,airspeed):
    #print("In send ADSB funtion\n")
    msg = ICAO + '\n'
    msg += str(pos_lat) + '\n'
    msg += str(pos_lon) + '\n'
    msg += str(pos_alt_rel) + '\n' # megan if you are hearing me, what is this []
    msg += str(velocity) + '\n'
    msg += str(round(airspeed,5)) + '\n'
    #make sure that this line works; changed from vehicle.battery.voltage to battery parameter
    print(msg)
    return msg

localXbee.add_data_received_callback(data_receive_callback)

# =========== TRANSMISSION / RECEPTION ===========
data_list = []
i = 0
n = 0
# localXbee.send_data_async(droneXbee, "hi drone")
while (True): 
    i += .00001
    n += .005
    localXbee.send_data_async(droneXbee, send_UAV_data_Xbee("A", float(34.04285) + i, float(-117.81194) + i, 10 - n, 0, 100))

    time.sleep(5)
    # print(i)
    # # print(str(i) + " sending")
    # # localXbee.send_data_async(droneXbee, "something")
    # # print(str(i) + " recieving")
    # message = localXbee.read_data(5) # Wait __ seconds before calling a timeout exception
    # data_list.append({'Sent Time': message.timestamp, 'Received Time': datetime.now().timestamp()})

localXbee.close()
print("XBee closed\n")