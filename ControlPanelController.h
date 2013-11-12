//
//  ControlPanelController.h
//  DynamixelMonitor
//
//  Created by Slavik on 11/11/13.
//  Copyright (c) 2013 LUCS. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ControlPanelController : NSWindowController

@property(nonatomic,strong) IBOutlet NSTableView * servoValues;

@property(nonatomic,strong) IBOutlet NSLevelIndicator * positionIndicator;
@property(nonatomic,strong) IBOutlet NSLevelIndicator * speedIndicator;
@property(nonatomic,strong) IBOutlet NSLevelIndicator * loadIndicator;
@property(nonatomic,strong) IBOutlet NSLevelIndicator * voltageIndicator;
@property(nonatomic,strong) IBOutlet NSLevelIndicator * temperatureIndicator;

@property(nonatomic,strong) IBOutlet NSSlider * goalPositionSlider;
@property(nonatomic,strong) IBOutlet NSSlider * movingSpeedSlider;

@property(nonatomic,strong) IBOutlet NSControl * torqueEnable;

@property(nonatomic,strong) IBOutlet NSToolbarItem* connectToolbarItem;
@property(nonatomic,strong) IBOutlet NSToolbarItem* torqueToolbarItem;

- (IBAction)connect:(id)sender;
- (IBAction)update:(id)sender;

- (IBAction)setGoalPosition:(id)sender;
- (IBAction)setSpeed:(id)sender;

- (IBAction)toggleTorque:(id)sender;
- (IBAction)torqueAllEnable:(id)sender;
- (IBAction)torqueAllDisable:(id)sender;

//- (IBAction)runScript:(id)sender;
//- (IBAction)stopScript:(id)sender;

@end
