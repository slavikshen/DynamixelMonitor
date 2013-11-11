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
#import "JSWrapper.h"
#import "Dynamixel.h"

@interface MyDocument()

@property(nonatomic,strong) Dynamixel* dynamixel;

@end

@implementation MyDocument {
    
    
    NSArray * controlTable;
    NSTimer * timer;
    
    BOOL newID;
    
}



-(void)timerFire:(NSTimer*)theTimer
{
    [self forceUpdate];
}

- (void)awakeFromNib {
 
    [super awakeFromNib];
    Dynamixel* d = [[Dynamixel alloc] init];
    self.dynamixel = d;
    [self loadJSContext];
    
}

- (void) dealloc {

    [self releaseJSContext];
    
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

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.dynamixel.allDynamixelServos.count;
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
            return [[NSString alloc] initWithFormat:@"%.1f V", (int)value/10.0f];
        
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
            return [[NSString alloc] initWithFormat:@"%.1f°", 300.0f*((int)value)/0x3ff];

        case 32: //Speed
            if(value > 0)
                return [[NSString alloc] initWithFormat:@"%.1f RPM", 114.0f*((int)value)/0x3ff];
            else
                return @"Max RPM";

        case 48: // Punch
            return [[NSString alloc] initWithFormat:@"%.1f%%", 100.0f*((int)value)/0x3ff];

        default:
            return [[NSString alloc] initWithFormat:@"%d", value];
    }
}




- (id)tableView:(NSTableView *)tableView
      objectValueForTableColumn:(NSTableColumn *)tableColumn
      row:(int)row
{
    ServoInfo* servo = self.dynamixel.allDynamixelServos[row];
 
    unsigned char* servoData = servo.servoData;
    NSString* identifier = [tableColumn identifier];
    
    if( [identifier isEqualToString:@"ID"] ) {
        NSString* name = [NSString stringWithFormat:@"ID-%ld", servo.sid];
        return name;
    }
    else if([identifier isEqualToString: @"Item"])
    {
        return [[controlTable objectAtIndex: row] objectForKey: [tableColumn identifier]];
    
    }
    else if([identifier isEqualToString: @"Value"])
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



- (IBAction)connect:(id)sender
{
    Dynamixel* d = self.dynamixel;
    if( nil == d ) {
        d = [[Dynamixel alloc] init];
        self.dynamixel = d;
    }
    
    if( ![d isConnected] ) {
        
        [d connect];
        
        [self.servoValues reloadData];
        [self.connectButton setTitle: @"Disconnect"];
        [self.torqueEnableButton setEnabled: YES];   // TODO: check first that we have connected
        [self.torqueDisableButton setEnabled: YES];
    }
    else
    {
        
        [d disconnect];
        
        [self.servoValues reloadData];
        [self.connectButton setTitle: @"Connect"];

        [self.torqueEnableButton setEnabled: NO];
        [self.torqueDisableButton setEnabled: NO];
    }
}



- (void)forceUpdate
{
    if( [self.dynamixel isConnected] ) {
        [self.dynamixel update];
        [self update: self];
    }

}



-(void)enableControls:(BOOL)enable
{
    [self.positionIndicator setEnabled: enable];
    [self.speedIndicator setEnabled: enable];
    [self.loadIndicator setEnabled: enable];
    [self.voltageIndicator setEnabled: enable];
    [self.temperatureIndicator setEnabled: enable];

    [self.goalPositionSlider setEnabled: enable];
    [self.movingSpeedSlider setEnabled: enable];

    [self.torqueEnable setEnabled: enable];

    [self.torqueEnableButton setEnabled: enable];
    [self.torqueDisableButton setEnabled: enable];
    
    if(!enable)
    {
        [self.positionIndicator setIntValue: 0];
        [self.speedIndicator setIntValue: 0];
        [self.loadIndicator  setIntValue: 0];
        [self.voltageIndicator setIntValue: 0];
        [self.temperatureIndicator setIntValue: 0];

        [self.goalPositionSlider setIntValue: 0];

        [self.torqueEnable setIntValue: 0];
    }
}



- (IBAction)update:(id)sender
{
    [self.servoValues reloadData];
    NSInteger index = [self.servoValues selectedRow];
    
    if( index == -1)
    {
        [self enableControls: NO];
        return;
    }
    
    ServoInfo* servo = self.dynamixel.allDynamixelServos[index];
    
    [self enableControls: YES];

    [self.positionIndicator setIntegerValue: servo.position];
    [self.speedIndicator setIntegerValue: servo.speed];
    [self.loadIndicator setIntegerValue:servo.load];
    
    [self.voltageIndicator setIntegerValue:servo.voltage];
    [self.temperatureIndicator setIntegerValue:servo.temperature];

    // Move the goal position with the servo if torque is disabled
    // or new ID is selected

    if( (0 == servo.torque || newID ) && self.dynamixel )
        [self.goalPositionSlider setIntegerValue:servo.position];

    [self.torqueEnable setIntegerValue:servo.torque];
    
    newID = NO;
}



- (IBAction)setGoalPosition:(id)sender
{
    int p = [self.goalPositionSlider intValue];
//    int s = [self.movingSpeedSlider intValue];
//    if(s == 1024) s = 0; // set maximum speed (no speed control) for maximal value
    
    NSInteger index = [self.servoValues selectedRow];
    ServoInfo* servo = self.dynamixel.allDynamixelServos[index];
    [self.dynamixel setPosition:p ofServo:servo.sid];
    
//    dc->Move([[idNumber objectAtIndex: [self.idList selectedRow]] intValue], p, s);
}



- (IBAction)setSpeed:(id)sender
{
    
    NSInteger index = [self.servoValues selectedRow];
    ServoInfo* servo = self.dynamixel.allDynamixelServos[index];

    int s = [self.movingSpeedSlider intValue];
    if(s == 1024) s = 0; // set maximum speed (no speed control) for maximum value

    [self.dynamixel setSpeed:s ofServo:servo.sid];
    
    [self forceUpdate];
}



- (IBAction)toggleTorque:(id)sender
{
//    dc->SetTorque([[idNumber objectAtIndex: [self.idList selectedRow]] intValue], [sender intValue]);
}


- (IBAction)torqueAllEnable:(id)sender
{
    [self.dynamixel torqueAllEnable];
}



- (IBAction)torqueAllDisable:(id)sender
{
    [self.dynamixel torqueAllDisable];
}



- (void) tableViewSelectionDidChange: (NSNotification *) notification
{
    NSInteger row = [self.servoValues selectedRow];
    if (row == -1) {
        //
    }
    else
    {
        newID = YES;
    }
}

- (IBAction)runScript:(id)sender {
    
    NSString* js = [NSString stringWithString:[[self.scriptEditor textStorage] string]];
    [self.jsWrapper evalScript:js];
    
}

- (IBAction)stopScript:(id)sender {
    [self.jsWrapper stopScript];
}

- (void)loadJSContext {
    
    JSWrapper* wrapper = [[JSWrapper alloc] init];
    wrapper.logView = (LogTextView*)(self.logView);
    wrapper.dynamixel = self.dynamixel;
    self.jsWrapper = wrapper;
    
    
}

- (void)releaseJSContext {
    self.jsWrapper = nil;
}

@end
