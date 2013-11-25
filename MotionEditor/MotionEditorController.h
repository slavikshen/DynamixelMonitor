//
//  MotionEditorController.h
//  DynamixelMonitor
//
//  Created by Slavik on 11/24/13.
//  Copyright (c) 2013 LUCS. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DocumentViewController.h"
#import "MotionDocument.h"

@interface MotionEditorController : DocumentViewController<NSTableViewDataSource,NSTableViewDelegate>

@property(nonatomic,strong) IBOutlet NSTableView* motionTableView;
@property(nonatomic,strong) IBOutlet NSTableView * servoValues;

@property(nonatomic,strong) IBOutlet NSLevelIndicator * positionIndicator;
@property(nonatomic,strong) IBOutlet NSLevelIndicator * speedIndicator;
@property(nonatomic,strong) IBOutlet NSLevelIndicator * loadIndicator;
@property(nonatomic,strong) IBOutlet NSLevelIndicator * voltageIndicator;
@property(nonatomic,strong) IBOutlet NSLevelIndicator * temperatureIndicator;

@property(nonatomic,strong) IBOutlet NSSlider * goalPositionSlider;
@property(nonatomic,strong) IBOutlet NSSlider * movingSpeedSlider;

@property(nonatomic,strong) IBOutlet NSControl * torqueEnable;

@property(nonatomic,strong) IBOutlet NSButton* globalTorqueEnable;

- (IBAction)setGoalPosition:(id)sender;
- (IBAction)setSpeed:(id)sender;

- (IBAction)toggleTorque:(id)sender;
//- (IBAction)torqueAllEnable:(id)sender;
//- (IBAction)torqueAllDisable:(id)sender;

- (IBAction)writeMotionToDroid:(id)sender;
- (IBAction)readMotionFromDroid:(id)sender;

- (IBAction)deleteMotion:(id)sender;
- (IBAction)playMotion:(id)sender;
- (IBAction)loopPlayMotion:(id)sender;
- (IBAction)stopPlayMotion:(id)sender;
- (IBAction)gotoNextMotion:(id)sender;


@end
