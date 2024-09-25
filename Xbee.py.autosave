# This Python file uses the following encoding: utf-8
# This Python file uses the following encoding: utf-8

from digi.xbee.devices import XBeeDevice, RemoteXBeeDevice, XBee64BitAddress
from digi.xbee.exception import XBeeException

class Xbee:
    # Replace with the port where your sender module is connected to.
    PORT = "/dev/ttyUSB0"
    # Replace with the baud rate of your sender module.
    BAUD_RATE = 9600

    def __init__(self, vehicle_id):
        self.my_device = XBeeDevice(self.PORT, self.BAUD_RATE)
        self.addressA = XBee64BitAddress("13A20041D365C4")
        self.xbeeA = RemoteXBeeDevice(self.my_device, self.addressA)
        self.addressC = XBee64BitAddress("13A200422F2FDF")
        self.xbeeC = RemoteXBeeDevice(self.my_device, self.addressC)
        ## need to think about the vehicle implementation, gets the id and can use that vehicle's functions?
        self.vehicle_id = vehicle_id

    # used for gui implementation last time
    ## need to chnage a bit to be implemented into our current code
    def connect_gcs_xbee(self):
        print(f"Xbee holding?: {self.my_device}")
        print("point b")

        try:
            # if device is already open, print message for user and close device
            if self.my_device.is_open():
                print("Already open")
                self.my_device.close()

            # try opening device, and if successful, print results for user
            print("Try open")
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

    # idk if we need this either
    ## might want to delete
    def receive_uav_xbee_data(self):
        msg = " "
        # reads data from xbee and prints it
        xbee_message = self.my_device.read_data()
        if xbee_message is not None:
            msg = xbee_message.data.decode()
            print(msg)

        return msg

    # used to test the command option
    ## We will need to change and see what we can do differently
    def send_command_to_xbee(self, icao_id):
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

    def struct_uav_xbee_data(self, msg):
        str_array = msg.split("\n")  # splits the string at "\n"
        m_map = {"ICAO": "initial value"}  # initial key-value pair

        # for loop to structure UAV xbee data
        for str_array1 in str_array:
            parsed_str = str_array1.split(": ")
            if len(parsed_str) == 2:
                m_map[parsed_str[0]] = parsed_str[1]

        return m_map

    # OLD callback message, we can disregard the data listener and add the async callback function directly, should work
    # def data_receive_callback(self, xbee_message):
        # # Callback function when data is received
        # print(f"Received data: {xbee_message.data.decode()}")

    # def data_receive_callback(self, xbee_message: XBeeMessage): (maybeeeee) idk the difference too much and if it is necessary
    def data_receive_callback(self, xbee_message):
        print("IN THE ASYNC FUNC")
        data_string = xbee_message.data.decode("utf-8")

        # Use the XbeeMain function to structure the received data
        messageMap = self.struct_uav_xbee_data(data_string)

        # Get the vehicle from the vehicle class
        ## implement the vehicle class
        selected_vehicle = GET VEHICLES FROM THE VEHICLE CLASS, may need to parse and do something, translations from python to c++

        # Convert data to Position and update vehicle's position
        try:
            # we might need to get re-think the messageMap
            currentLongitude = float(messageMap["Lattitude"])
            currentLatitude = float(messgageMap["Longitude"])
            selected_vehicle.set_current_position(currentLongitude, currentLattitude, 0)
        except ValueError as e:
            print(f"Error parsing position: {e}")
            return

        # Update flight log GUI for certain vehicles
        ## might need to rethink the python script that we have running on the drone's side and will need to change how we parse
        ## the messages we receive
        if selected_vehicle.get_icao_id() in ["A", "C"]:
            vehicle_flight_log = selected_vehicle.get_flight_log_gui()
            print(f"ICAO: {messageMap.get('ICAO')}")
            vehicle_flight_log.set_lat_val(messageMap.get("Lattitude"))
            vehicle_flight_log.set_long_val(messageMap.get("Longitude"))
            vehicle_flight_log.set_alt_val(messageMap.get("Altitude"))
            vehicle_flight_log.set_vel_val(messageMap.get("Velocity"))
            vehicle_flight_log.set_air_val(messageMap.get("Airspeed"))
            vehicle_flight_log.set_bat_lvl_val(messageMap.get("Battery Level"))

        # Track the vehicle's path if needed
        ## we need to change this pathing to toggle on and off within the GUI
        if selected_vehicle.should_track_path():
            selected_vehicle.setCurrentLongitude(currentLongitude)
            selected_vehicle.setCurrentLattitude(currentLattitude)
            selected_vehicle.togglePath()


        ## Everything below, we are going to need to alter and fit our usecase!
        ## however i will keep it here for now so we know previous functionality for the GUI and what to implement


        # Calculate averages for latitude and longitude
        ## do we need this code?
        avg_lat = GCSClean8.Vehicle.get_avg_lat()
        avg_lon = GCSClean8.Vehicle.get_avg_lon()

        print(f"Drone count?: {GCSClean8.Vehicle.get_drone_count()}")

        # Update average lat/lon with respect to the number of drones
        avg_lat *= GCSClean8.Vehicle.get_drone_count()
        avg_lon *= GCSClean8.Vehicle.get_drone_count()

        print(f"Latitude: {selected_vehicle.get_lat()}")
        print(f"Longitude: {selected_vehicle.get_lon()}")

        avg_lat -= selected_vehicle.get_lat()
        avg_lon -= selected_vehicle.get_lon()

        print(f"avgLat 0: {avg_lat}")
        print(f"avgLon 0: {avg_lon}")

        avg_lat += float(messageMap["Lattitude"])
        avg_lon += float(messageMap["Longitude"])

        print(f"avgLat: {avg_lat}")
        print(f"avgLon: {avg_lon}")

        avg_lat /= GCSClean8.Vehicle.get_drone_count()
        avg_lon /= GCSClean8.Vehicle.get_drone_count()

        # Update the selected vehicle's lat/lon and global average lat/lon
        selected_vehicle.set_lat(float(messageMap["Lattitude"]))
        selected_vehicle.set_lon(float(messageMap["Longitude"]))
        GCSClean8.Vehicle.set_avg_lat(avg_lat)
        GCSClean8.Vehicle.set_avg_lon(avg_lon)

        # Update the app frame's view based on the new average position
        average_position = Position.from_degrees(avg_lat, avg_lon)
        self.af.change_view(average_position)

        # Redraw the WorldWind display to reflect new vehicle positions
        self.af.get_wwd().redraw()

# Testing function if X-bee works. Main will never be called in GCS
## Needs to be looked at in future implementation. This main function was only called to test the program,
## however in the style in which this file was included in the GUI, the main was never called which is what we want
# if needed we can get ride of the stuff inside main
if __name__ == "__main__":
    computer_xbee = xbee()
    print("Point a")
    computer_xbee.connect_gcs_xbee()

    try:
        while True:
            msg = computer_xbee.receive_uav_xbee_data()
            print(" ++++++++++++++")

            m_map = computer_xbee.struct_uav_xbee_data(msg)

            # show the connection of the xbee and whether or not it has connected
            for key, value in m_map.items():
                print(f"{key} {value}")
    finally:
        print("Closing xbee connection......")
        computer_xbee.close_xbee_port()
