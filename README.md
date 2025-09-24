# The Ground Control Station for Fire-Detection and Suppression
This is a student-run project from California State Polytechnic University, Pomona. 
Supervised by [Dr. Subodh Bhandari](https://www.linkedin.com/in/subodh-bhandari-153b6414/), in collaboration with [Lockheed Martin](https://lockheedmartin.com/)

## The mission 
Building a GCS that enables: 
- autonomous control of UAV fleets,
- real-time fire detection and mapping,
- monitoring and coordination of UAVs for fire suppression,
- a **UAV-agnostic platform** that can be deployed across our campus and beyond.

### Our working MVP
"We want to be able to hand this off to another drone team. they’re able to connect their drones (simply inputting the information from their XBees). They fly the drones by setting waypoints on the GCS and are able to see the drones on the map. They’re able to see the drone telemetry. They’re able to send commands for returning home and taking off. This software will be more fun to use than what’s out there."

## The application
We are building the GCS using the Qt Framework, chosen for its:
- Cross-platform support (Windows, Linux, macOS)
- Integration with QML for responsive UI design
- Signal/slot mechanism for UAV telemetry as well as cross UI functionality 
- Ability to interface with Python processes (e.g., for XBee communication)

## The GCS Leads
- Megan Bee, Co-Lead
- Carlos Vargas, Co-Lead
- Ryan Vu, Senior Developer
- Danny Caceres, Senior Developer
