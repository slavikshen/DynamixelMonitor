DynamixelMonitor - ReadMe

DynamixelMonitor is a simple application that can control Dynamixel servos through
a USB2Dynamixel from ROBOTIS and presumably also other USB-to-Serial interfaces.
The current version only works with a direct connection to the Dynamixel bus for
servos set for communication at 1 Mbps (which is the default). The application has
only been tested with AX-12+ but should work also with other Dynamixels.

The interface is written in Cocoa/Objective-C while the communication with the Dynamixel
servos is borrowed from the Ikaros project (www.ikaros-project.org) and written in C++. .

This code is distributed under the GPL licence.

Let me know if you find the code useful or want to add features to it.

Christian Balkenius (christian.balkenius@lucs.lu.se)

