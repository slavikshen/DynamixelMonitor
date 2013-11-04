//
//    MyDocument.h
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


#import <Cocoa/Cocoa.h>

#include "DynamixelComm.h"

@interface MyDocument : NSDocument
{
    IBOutlet NSTableView * idList;
    IBOutlet NSTableView * servoValues;
    IBOutlet NSButton * connectButton;

    IBOutlet NSLevelIndicator * positionIndicator;
    IBOutlet NSLevelIndicator * speedIndicator;
    IBOutlet NSLevelIndicator * loadIndicator;
    IBOutlet NSLevelIndicator * voltageIndicator;
    IBOutlet NSLevelIndicator * temperatureIndicator;

    IBOutlet NSSlider * goalPositionSlider;
    IBOutlet NSSlider * movingSpeedSlider;

    IBOutlet NSControl * torqueAuto;
    IBOutlet NSControl * torqueEnable;

    IBOutlet NSControl * torqueEnableButton;
    IBOutlet NSControl * torqueDisableButton;
            
    NSArray * controlTable;
    NSMutableArray * ID;
    NSMutableArray * idNumber;

    DynamixelComm * dc;
    
    BOOL    newID;
    
    unsigned char servoData[128];
    NSTimer * timer;
}

@property(nonatomic,strong) IBOutlet NSTextView* scriptEditor;
@property(nonatomic,strong) IBOutlet NSTextView* logView;


- (IBAction)connect:(id)sender;
- (IBAction)update:(id)sender;

- (IBAction)setGoalPosition:(id)sender;
- (IBAction)setSpeed:(id)sender;
- (IBAction)toggleTorque:(id)sender;

- (IBAction)torqueAllEnable:(id)sender;
- (IBAction)torqueAllDisable:(id)sender;

@end
