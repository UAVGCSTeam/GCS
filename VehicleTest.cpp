// Preface:
// I have never coded in C++ so I wanted to just get a very simple class working first before trying to
// implement special features that have to do with XBee communication. I'm also not 100% sure I'm going
// in the right direction/structure with what I have right now, but this is just a test class basically!

#include <iostream>
#include <string>

using namespace std;

class Vehicle
{
public:
    static int vehicleCount;

    string name;
    int id;
    string state = "IDLE";
    float latitude = 0;
    float longitude = 0;
    float altitude = 0;

    Vehicle(const string &vehicleName, int vehicleId)
        : name(vehicleName)
        , id(vehicleId)
    {}

    string checkState()
    {
        cout << "Vehicle '" << name << "' is currently " << state << endl;
        return state;
    }

    void turnOn()
    {
        state = "ON";
        cout << "Vehicle '" << name << "' has been turned " << state << endl;
        vehicleCount++;
    }

    void turnOff()
    {
        state = "OFF";
        cout << "Vehicle '" << name << "' has been turned " << state << endl;
        vehicleCount--;
    }

    static int getVehicleCount()
    {
        cout << "There are currently " << vehicleCount << " vehicle(s) running" << endl;
        return vehicleCount;
    }

    void printLocation()
    {
        cout << name << " | Latitude: " << latitude << " | Longitude: " << longitude
             << " | Altitude: " << longitude << endl;
        vehicleCount--;
    }
};

int Vehicle::vehicleCount = 0;

int main()
{
    Vehicle v1("My Vehicle", 1);
    v1.checkState();
    v1.turnOn();
    v1.checkState();
    v1.turnOff();

    Vehicle v2("Team Vehicle", 2);
    v2.turnOn();
    Vehicle::getVehicleCount();

    v1.printLocation();
    return 0;
}
