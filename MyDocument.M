//
//    MyDocument.M
//
//    Copyright (C) 2010  Christian Balkenius
//
//    This program is free software; you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation; either version 2 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program; if not, write to the Free Software
//    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//
//    Created: April 1, 2010
//
//    The .M suffix in the file name is necessary to call C++ from objective-C
//


#import "MyDocument.h"

#include "DynamixelComm.h"

@implementation MyDocument



-(void)timerFire:(NSTimer*)theTimer
{
    if(dc && [idList selectedRow] != -1)
        dc->ReadAllData([[idNumber objectAtIndex: [idList selectedRow]] intValue], servoData);
    [self update: self];
}



- (id)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}



- (NSString *)windowNibName
{
    return @"MyDocument";
}



- (NSString *)displayName
{
    return @"Dynamixel Monitor";
}


- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];

    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource: @"AX12" ofType: @"plist"];   // The AX12 file is currently used for all servo types (they all seem to be the same)
        
    controlTable = [NSArray arrayWithContentsOfFile: path];
    
    ID = [NSMutableArray arrayWithCapacity: 128];
    idNumber = [NSMutableArray arrayWithCapacity: 128];


    dc = NULL;
    newID = NO;

    timer = [NSTimer scheduledTimerWithTimeInterval:0.1
        target:self
        selector:@selector(timerFire:)
        userInfo:nil
        repeats:YES];
}


/*

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.

    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.

    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return nil;
}



- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.

    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
    
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.
    
    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
    return YES;
}

*/


- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
    if([tableView tag] == 0)
    {
//        NSLog(@"ID count = %d", [ID count]);
        return [ID count];    
    }
    else
    {
        if([idList selectedRow] == -1)
            return 0;
        else
            return [controlTable count];
    }
}



// Function that translates the values in the control table to a more readable form
//
// This could probably be done more elegantly by adding conversion information and units to the 
// property list file for each servo type

-(NSString *)translateValue:(unsigned int)value atAddress: (unsigned int)address
{
    switch(address)
    {
        case 0: // Model Number
            switch(value)
            {
                case 10:   return @"RX-19";
                case 64:   return @"RX-64";
                case 12:   return @"AX-12"; // no difference between AX-12 and AX-12+ ???
                case 113:  return @"DX-113";
                case 116:  return @"DX-116";
                case 117:  return @"DX-117";
                case 106:  return @"EX-106"; // this is just a guess
                default:   return @"Unkown dynamixel";
            }
            
            return (value == 12 ? @"AX-12" : @"Unkown dynamixel");
    
        case 4: // Buad Rate
            if(value == 1)
                return @"1 Mbps";
            else if(value <10)
                return [[NSString alloc] initWithFormat:@"%d kbps", 2000/(1+value)];
            else
                return [[NSString alloc] initWithFormat:@"%d bps", 2000000/(1+value)];

        case 5: // Return Delay Time
            return [[NSString alloc] initWithFormat:@"%d μs", 2*value];
        
        case 16: // Status Return Level
            switch(value)
            {
                case 0:  return @"Never";
                case 1:  return @"READ_DATA only";
                case 2:  return @"Always";
                default: return @"Illegal value";
            }
            
        case 24: // ON/OFF
        case 25:
            return (value == 0 ? @"Off" : @"On");

        case 17: // Status Return Level
        case 18: // Alarm Shutdown
            return [[NSString alloc] initWithFormat:@"%d", value]; // Check the bits here => IOCRHAV
        
        case 11: // Temperatures
        case 43:
            return [[NSString alloc] initWithFormat:@"%d °C", value];
            
        case 12: // Voltages
        case 13:
        case 42:
            return [[NSString alloc] initWithFormat:@"%.1f V", float(value)/10];
        
        case 38: // Speed/Load
        case 40:
            if(value == 0)
                return @"0";
            else if(value < 1024)
                return [[NSString alloc] initWithFormat:@"+%d", value];
            else
                return [[NSString alloc] initWithFormat:@"-%d", value-1024];

        case 6: // Angles
        case 8:
        case 30:
        case 36:
        case 26: // We assume that the correct unit for the compliance parameters is in degrees
        case 27:
        case 28:
        case 29:
            return [[NSString alloc] initWithFormat:@"%.1f°", 300.0f*float(value)/float(0x3ff)];

        case 32: //Speed
            if(value > 0)
                return [[NSString alloc] initWithFormat:@"%.1f RPM", 114.0f*float(value)/float(0x3ff)];
            else
                return @"Max RPM";

        case 48: // Punch
            return [[NSString alloc] initWithFormat:@"%.1f%%", 100.0f*float(value)/float(0x3ff)];

        default:
            return [[NSString alloc] initWithFormat:@"%d", value];
    }
}




- (id)tableView:(NSTableView *)tableView
      objectValueForTableColumn:(NSTableColumn *)tableColumn
      row:(int)row
{
    if([tableView tag] == 0)
    {
        return [ID objectAtIndex: row];
    }
    
    else
    {
        if([[tableColumn identifier] isEqualToString: @"Item"])
        {
            return [[controlTable objectAtIndex: row] objectForKey: [tableColumn identifier]];
        
        }
        else if([[tableColumn identifier] isEqualToString: @"Value"])
        {
            int address = [[[controlTable objectAtIndex: row] objectForKey: @"Address"] intValue];
            int size = [[[controlTable objectAtIndex: row] objectForKey: @"Size"] intValue];

            if(size == 1)
                return [self translateValue: servoData[address] atAddress: address];
            else
                return [self translateValue: servoData[address]+256*servoData[address+1] atAddress: address];
        }
        else // Raw
        {
            int address = [[[controlTable objectAtIndex: row] objectForKey: @"Address"] intValue];
            int size = [[[controlTable objectAtIndex: row] objectForKey: @"Size"] intValue];
            if(size == 1)
                return [[NSString alloc] initWithFormat:@"%d", servoData[address]];
            else
                return [[NSString alloc] initWithFormat:@"%d", servoData[address]+256*servoData[address+1]];
        }
    }
}



- (IBAction)connect:(id)sender
{       
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *device = [defaults stringForKey:@"device"];
    if(device == nil) device = @"/dev/cu.usbserial-A7005Lxn";
    
    if(!dc)
    {    
        try
        {
            dc = new DynamixelComm([device UTF8String], 1000000);
        }
        catch(...)
        {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Could not find USB2Dynamixel"];
            [alert setInformativeText:@"Check that the cable is connected and that the device name is set correctly in the preferences."];
            [alert setAlertStyle:NSWarningAlertStyle];

            if ([alert runModal] == NSAlertFirstButtonReturn) {
                // OK clicked, delete the record
            }
            return;
        }
        
        // Scan for dynamixels
        
        [ID removeAllObjects];
        
        for(int i=0; i<32; i++)
        {
            if(dc->Ping(i))
            {
            //  NSLog(@"ID = %d found", i);
                [ID addObject: [[NSString alloc] initWithFormat:@"ID-%d", i]];
                [idNumber addObject: [NSNumber numberWithInt: i]];
            }
        }
        [idList reloadData];
        [connectButton setTitle: @"Disconnect"];
        [torqueEnableButton setEnabled: YES];   // TODO: check first that we have connected
        [torqueDisableButton setEnabled: YES];
    }
    else
    {
//        NSLog(@"Disconnect");
        delete dc;
        dc = NULL;
        [ID removeAllObjects];
        [idList reloadData];
        [connectButton setTitle: @"Connect"];

        [torqueEnableButton setEnabled: NO];
        [torqueDisableButton setEnabled: NO];
    }
}



- (void)forceUpdate
{
    if(dc && [idList selectedRow] != -1)
        dc->ReadAllData([[idNumber objectAtIndex: [idList selectedRow]] intValue], servoData);

    [servoValues reloadData];
    [servoValues display];      // Force redraw

    // Update controls
    
    if([idList selectedRow] == -1)
        return;

    [positionIndicator setIntValue: servoData[P_PRESENT_POSITION_L]+256*servoData[P_PRESENT_POSITION_H]];
    
    unsigned int speed = servoData[P_PRESENT_SPEED_L]+256*servoData[P_PRESENT_SPEED_H];
    if(speed < 1024)
        [speedIndicator setIntValue: speed];
    else
        [speedIndicator setIntValue: speed-1024];
        
    int load = servoData[P_PRESENT_LOAD_L]+256*servoData[P_PRESENT_LOAD_H];
    if(load >= 1024) load -= 1024;
    [loadIndicator setIntValue: load];

    [voltageIndicator setIntValue: servoData[P_PRESENT_VOLTAGE]];
    [temperatureIndicator setIntValue: servoData[P_PRESENT_TEMPERATURE]];

    // Move the goal position with the servo if torque is disabled

    if(servoData[P_TORQUE_ENABLE] == 0 && dc) //  && [goalTracking  intValue] 
        [goalPositionSlider setIntValue: servoData[P_PRESENT_POSITION_L]+256*servoData[P_PRESENT_POSITION_H]];

    [torqueEnable setIntValue: servoData[P_TORQUE_ENABLE]];

}



-(void)enableControls:(BOOL)enable
{
    [positionIndicator setEnabled: enable];
    [speedIndicator setEnabled: enable];
    [loadIndicator setEnabled: enable];
    [voltageIndicator setEnabled: enable];
    [temperatureIndicator setEnabled: enable];

    [goalPositionSlider setEnabled: enable];
    [movingSpeedSlider setEnabled: enable];

    [torqueEnable setEnabled: enable];

    [torqueEnableButton setEnabled: enable];
    [torqueDisableButton setEnabled: enable];
    
    if(!enable)
    {
        [positionIndicator setIntValue: 0];
        [speedIndicator setIntValue: 0];
        [loadIndicator  setIntValue: 0];
        [voltageIndicator setIntValue: 0];
        [temperatureIndicator setIntValue: 0];

        [goalPositionSlider setIntValue: 0];

        [torqueEnable setIntValue: 0];
    }
}



- (IBAction)update:(id)sender
{
    [servoValues reloadData];
    
    if([idList selectedRow] == -1)
    {
        [self enableControls: NO];
        return;
    }
    
    [self enableControls: YES];

    [positionIndicator setIntValue: servoData[P_PRESENT_POSITION_L]+256*servoData[P_PRESENT_POSITION_H]];
    
    unsigned int speed = servoData[P_PRESENT_SPEED_L]+256*servoData[P_PRESENT_SPEED_H];
    if(speed < 1024)
        [speedIndicator setIntValue: speed];
    else
        [speedIndicator setIntValue: speed-1024];
        
    int load = servoData[P_PRESENT_LOAD_L]+256*servoData[P_PRESENT_LOAD_H];
    if(load >= 1024) load -= 1024;
    [loadIndicator setIntValue: load];
    
    [voltageIndicator setIntValue: servoData[P_PRESENT_VOLTAGE]];
    [temperatureIndicator setIntValue: servoData[P_PRESENT_TEMPERATURE]];

    // Move the goal position with the servo if torque is disabled
    // or new ID is selected

    if((servoData[P_TORQUE_ENABLE] == 0 || newID) && dc)
        [goalPositionSlider setIntValue: servoData[P_PRESENT_POSITION_L]+256*servoData[P_PRESENT_POSITION_H]];

    [torqueEnable setIntValue: servoData[P_TORQUE_ENABLE]];
    
    newID = NO;
}



- (IBAction)setGoalPosition:(id)sender
{
    int p = [goalPositionSlider intValue];
    int s = [movingSpeedSlider intValue];
    if(s == 1024) s = 0; // set maximum speed (no speed control) for maximal value
    dc->Move([[idNumber objectAtIndex: [idList selectedRow]] intValue], p, s);
}



- (IBAction)setSpeed:(id)sender
{
    int s = [movingSpeedSlider intValue];
    if(s == 1024) s = 0; // set maximum speed (no speed control) for maximum value
    dc->SetSpeed([[idNumber objectAtIndex: [idList selectedRow]] intValue], s);
    
    [self forceUpdate];
}



- (IBAction)toggleTorque:(id)sender
{
    dc->SetTorque([[idNumber objectAtIndex: [idList selectedRow]] intValue], [sender intValue]);
}



- (IBAction)torqueAllEnable:(id)sender
{
    dc->SetTorque(254, 1);
}



- (IBAction)torqueAllDisable:(id)sender
{
    dc->SetTorque(254, 0);
}



- (void) tableViewSelectionDidChange: (NSNotification *) notification
{
    int row;

    if([notification object] == idList)
    {
        row = [idList selectedRow];

        if (row == -1) {
            //
        }
        else
        {
            newID = YES;
        }
    }
}


@end
