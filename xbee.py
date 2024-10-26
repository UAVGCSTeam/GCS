import vehicle

# This Python file uses the following encoding: utf-8
from digi.xbee.devices import XBeeDevice, RemoteXBeeDevice #, XBee64BitAddress
from digi.xbee.exception import XBeeException
from digi.xbee.models.address import XBee64BitAddress

class Xbee:
    PORT = "COM3" # need to change when we get new xbees (COM3: A)
    # Replace with the baud rate of your sender module.
    BAUD_RATE = 9600
    

    def __init__(self):
        self.my_device = XBeeDevice(self.PORT, self.BAUD_RATE)
        self.addressA = XBee64BitAddress.from_hex_string("13A20041D365C4")
        self.xbeeA = RemoteXBeeDevice(self.my_device, self.addressA)
        self.addressC = XBee64BitAddress.from_hex_string("13A200422F2FDF")
        self.xbeeC = RemoteXBeeDevice(self.my_device, self.addressC)

    # used for gui implementation last time
    ## need to chnage a bit to be implemented into our current code
    def connect_gcs_xbee(self):
        print("trying to connect xbee...")
        try:
            # if device is already open, print message for user and close device
            if self.my_device.is_open():
                print("Already open")
                self.my_device.close()

            # try opening device, and if successful, print results for user
            self.my_device.open()
            print("Successfully opened")
            self.my_device.add_data_received_callback(self.data_receive_callback)
        except XBeeException as e:
            print("myDevice.open() >> Error")
            print(e)
            exit(1)  # close program
        except Exception as e:
            print("myDevice.close() >> Error")
            print(e)

    def close_xbee_port(self):
        self.my_device.close()

    def check_xbee_port_connection(self):
        return self.my_device.is_open()

    # used to test the command option
    ## We will need to change and see what we can do differently
    def send_command_to_xbee(self, icao_id, msg):
        try:
            if icao_id == "A":
                msg = "hi A"
                data_to_send = msg.encode()
                self.my_device.send_data_async(self.xbeeA, data_to_send)
            else:
                msg = "hi C"
                data_to_send = msg.encode()
                self.my_device.send_data_async(self.xbeeC, data_to_send)
        except XBeeException as e:
            print("Error")
            print(e)
            exit(1)

    # OLD callback message, we can disregard the data listener and add the async callback function directly, should work
    # this is where we are going to need to connect the Vehichle class to the python script
    def data_receive_callback(self, xbee_message):
        # Callback function when data is received
        print(f"Received data: {xbee_message.data.decode()}")

if __name__ == "__main__":
    # id = 'B'
    computer_xbee = Xbee()
    print("Point a")
    computer_xbee.connect_gcs_xbee()
    

    try:
        while True:
            hi = "hi"

    finally:
        print("Closing xbee connection......")
        computer_xbee.close_xbee_port()
