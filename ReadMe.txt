
DynamixelMonitor

# Intro

This project is base on the sample code written by Christian Balkenius (christian.balkenius@lucs.lu.se) from robosavvy (http://goo.gl/WBOhZs).

DynamixelMonitor is a simple application that can control Dynamixel servos through
a USB2Dynamixel from ROBOTIS and presumably also other USB-to-Serial interfaces.
The current version only works with a direct connection to the Dynamixel bus for
servos set for communication at 1 Mbps (which is the default). The application has
only been tested with AX-12+ but should work also with other Dynamixels.

The interface is written in Cocoa/Objective-C while the communication with the Dynamixel
servos is borrowed from the Ikaros project (www.ikaros-project.org) and written in C++. .

Currently, I am trying to add javascript to the app in order to control the servos for advance purposes.

This code is distributed under the GPL licence.

# What you need to run this project

1 USB2Dynamixel adaptor
2 Dynamixel Servos
3 Battery to power your servos

# How to use javascript

There are two object for developer

console &
D

The console object is the same as the one in web browser.  It can be used to output debug message.

The D object is used to represent the dynamixel servo controller.
It implement the serial port commnunication protocol to control the servos.

To change the servo postion

D.setPositionOfServo( position, servo_id );


You can check the DynamxielJSExport protocol for more js functions.


