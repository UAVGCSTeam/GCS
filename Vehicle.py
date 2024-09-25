# This Python file uses the following encoding: utf-8
from digi.xbee.devices import XBeeDevice
from threading import Thread
import time

class Vehicle:
    drone_count = 0
    vehicle_list = {}
    flight_log_vehicle = None

    ## think about how we want to get the xbee_port and baud_rate to store information, if its in the files hardcoded or not

    ## as for the information we need about the drone, we need to think about how that's going to be implemented in the GUI
    ## what is the information we need to hold and how would be do that?
    ## what are the other methods, static and nonstatic, within this class for future implementation
    def __init__(self, ICAO_ID, xbee_port, baud_rate):
        self.ID_number = Vehicle.drone_count
        self.ICAO_ID = ICAO_ID        # need to get this from the GUI
        self.drone_type = None
        self.track_path = True
        ## need to re-think how we should hold data
        self.path_position_list = []  # Stores drone positions (could be lat/lon tuples)
        self.current_position = None  # Current position of the drone
        self.current_longitude = None
        self.current_lattitude = None
        self.track_in_view = True
        self.xbee = XBeeDevice(xbee_port, baud_rate)  # Initialize XBee device
        self.animation_thread = None
        Vehicle.drone_count += 1

    @staticmethod
    def get_flight_log_vehicle():
        return Vehicle.flight_log_vehicle

    @staticmethod
    def set_flight_log_vehicle(vehicle_to_be_set):
        Vehicle.flight_log_vehicle = vehicle_to_be_set

    def add_to_list(self):
        Vehicle.vehicle_list[self.ID_number] = self

    def get_id(self):
        return self.ID_number

    def get_ICAO_ID(self):
        return self.ICAO_ID

    def change_track_path(self):
        self.track_path = not self.track_path

    # repetitive in terms of the previous method, don't know which one would be better to implement right now
    def should_track_path(self):
        return self.track_path

    ## not good, think of better data implementation
    def add_position(self, next_position):
        self.path_position_list.append(next_position)
        print(f"Path list updated: {self.path_position_list}")

    def change_track_in_view(self):
        self.track_in_view = not self.track_in_view

    # again as something above, repetitiveness
    def should_track_in_view(self):
        return self.track_in_view

    def set_current_position(self, current_longitude, current_lattitude):
        self.current_position = [current_longitude, current_lattitude, 0]
        # print(f"Updated position for drone {self.ID_number}: {self.current_position}")

    def get_current_position(self):
        return self.current_position

    def set_drone_type(self, drone_type):
        self.drone_type = drone_type

    def get_drone_type(self):
        return self.drone_type

    def start_xbee(self):
        # Start the XBee device
        try:
            self.xbee.connect_gcs_xbee()
            print(f"XBee Device {self.ID_number} opened successfully.")
        except Exception as e:
            print(f"Failed to open XBee Device {self.ID_number}: {e}")

    def stop_xbee(self):
        # Close the XBee device
        if self.xbee.is_open():
            self.xbee.close()
            print(f"XBee Device {self.ID_number} closed.")

    def xbee_receive_data(self):
        # Function to receive data from XBee
        def data_receive_callback(xbee_message):
            print("Received data from %s: %s" % (xbee_message.remote_device.get_64bit_addr(),
                                                 xbee_message.data.decode()))

        self.xbee.add_data_received_callback(data_receive_callback)

    # we have implemented threads into our previous gui, however I am not as familiar
    ## look into if we need threads or if starting threads is necessary for this project and if it belongs in the Vehicle class

