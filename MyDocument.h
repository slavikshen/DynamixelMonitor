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

@class JSWrapper;

@interface MyDocument : NSDocument

@property(nonatomic,strong) IBOutlet NSTableView * idList;
@property(nonatomic,strong) IBOutlet NSTableView * servoValues;
@property(nonatomic,strong) IBOutlet NSButton * connectButton;

@property(nonatomic,strong) IBOutlet NSLevelIndicator * positionIndicator;
@property(nonatomic,strong) IBOutlet NSLevelIndicator * speedIndicator;
@property(nonatomic,strong) IBOutlet NSLevelIndicator * loadIndicator;
@property(nonatomic,strong) IBOutlet NSLevelIndicator * voltageIndicator;
@property(nonatomic,strong) IBOutlet NSLevelIndicator * temperatureIndicator;

@property(nonatomic,strong) IBOutlet NSSlider * goalPositionSlider;
@property(nonatomic,strong) IBOutlet NSSlider * movingSpeedSlider;

@property(nonatomic,strong) IBOutlet NSControl * torqueAuto;
@property(nonatomic,strong) IBOutlet NSControl * torqueEnable;

@property(nonatomic,strong) IBOutlet NSControl * torqueEnableButton;
@property(nonatomic,strong) IBOutlet NSControl * torqueDisableButton;


@property(nonatomic,strong) IBOutlet NSTextView* scriptEditor;
@property(nonatomic,strong) IBOutlet NSTextView* logView;
@property(nonatomic,strong) JSWrapper* jsWrapper;


- (IBAction)connect:(id)sender;
- (IBAction)update:(id)sender;

- (IBAction)setGoalPosition:(id)sender;
- (IBAction)setSpeed:(id)sender;
- (IBAction)toggleTorque:(id)sender;

- (IBAction)torqueAllEnable:(id)sender;
- (IBAction)torqueAllDisable:(id)sender;

- (IBAction)runScript:(id)sender;

@end
