//
//  MotionEditorController.m
//  DynamixelMonitor
//
//  Created by Slavik on 11/24/13.
//  Copyright (c) 2013 LUCS. All rights reserved.
//

#import "MotionEditorController.h"
#import "Dynamixel.h"

NSString* const kMotionEditorControllerProperty_CurrentMotion = @"currentMotion";
NSString* const kMotionEditorControllerProperty_CurrentServoInfo = @"currentServoInfo";

@interface MotionEditorController ()

// current selected motion
@property(nonatomic,strong) Motion* currentMotion;
// current selected servo info in the current motion
@property(nonatomic,strong) ServoInfo* currentServoInfo;

@property(nonatomic,assign) BOOL enableControl;
@property(nonatomic,readonly) BOOL puppetMode;

@property(nonatomic,strong) NSTimer* refreshTimer;

@end

@implementation MotionEditorController {
 
    BOOL _switchingServoSelection;
    
}

- (void)setDocument:(id)document {
 
    MotionDocument* prevDoc = self.document;
    if( prevDoc ) {
        [prevDoc removeObserver:self constantKeys:@[kMotionDocumentProperty_Motions]];
    }
    
    [super setDocument:document];
    
    MotionDocument* doc = self.document;
    if( doc ) {
        [doc addObserver:self constantKeys:@[kMotionDocumentProperty_Motions]];
        [self.motionTableView reloadData];
    }
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self addObserver:self constantKeys:@[kMotionEditorControllerProperty_CurrentMotion,
                                              kMotionEditorControllerProperty_CurrentServoInfo
                                              ]];
        Dynamixel* d = [Dynamixel sharedInstance];
        [d addObserver:self constantKeys:@[kDynamixelProperty_Connected,kDynamixelProperty_TorqueEnabled]];
    }
    return self;
}

- (void)dealloc {
    [self removeObserver:self constantKeys:@[kMotionEditorControllerProperty_CurrentMotion,
                                          kMotionEditorControllerProperty_CurrentServoInfo
                                          ]];
    Dynamixel* d = [Dynamixel sharedInstance];
    [d removeObserver:self constantKeys:@[kDynamixelProperty_Connected,kDynamixelProperty_TorqueEnabled]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
 
    if( (__bridge void*)kMotionDocumentProperty_Motions == context ) {
        [self _handleMotionsChange:change];
    } else if((__bridge void*)kMotionEditorControllerProperty_CurrentServoInfo == context) {
        [self _reloadSelectedServoInfo];
    } else if((__bridge void*)kMotionEditorControllerProperty_CurrentMotion == context) {
        [self _reloadSelectedMotion];
    } else if((__bridge void*)kDynamixelProperty_TorqueEnabled == context ) {
        // refresh the torque
        [self _reloadTorqueStatus];
    } else if((__bridge void*)kDynamixelProperty_Connected == context ) {
        [self _reloadTimer];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
}

- (void)setRefreshTimer:(NSTimer *)refreshTimer {
 
    if( _refreshTimer ) {
        [_refreshTimer invalidate];
    }
    _refreshTimer = refreshTimer;
}

- (void)_reloadTimer {
    Dynamixel* d = [Dynamixel sharedInstance];
    NSTimer* refresher = nil;
    if( d.connected ) {
        refresher = [NSTimer scheduledTimerWithTimeInterval:1
                                                     target:self
                                                   selector:@selector(_updateServos)
                                                   userInfo:nil
                                                    repeats:YES];
    }
    self.refreshTimer = refresher;
}

- (void)_updateServos {
 
    Dynamixel* d = [Dynamixel sharedInstance];
    [d update];
    
    if( [self puppetMode] ) {
        [self.servoValues reloadData];
    }
    
}

- (void)awakeFromNib {
 
    [super awakeFromNib];
    
    Dynamixel* d = [Dynamixel sharedInstance];
    if( ![d isConnected] ) {
        [d connect];
        [self _reloadTimer];
    }
    
    self.enableControl = NO;
    [self _reloadTorqueStatus];
    
    NSTableView* mTableView = self.motionTableView;
    [mTableView setDoubleAction:@selector(_doubleClickMotion:)];
    [mTableView setTarget:self];
}

- (void)_handleMotionsChange:(NSDictionary*)change {
    
    NSInteger type = [change[NSKeyValueChangeKindKey] integerValue];
    NSIndexSet* indexSet = change[NSKeyValueChangeIndexesKey];

    NSTableView* mTableView = self.motionTableView;
    
    switch( type ) {
        case NSKeyValueChangeSetting:
            [mTableView reloadData];
            break;
        case NSKeyValueChangeInsertion:
            [mTableView beginUpdates];
            [mTableView insertRowsAtIndexes:indexSet withAnimation:NSTableViewAnimationEffectNone];
            [mTableView endUpdates];
            break;
        case NSKeyValueChangeRemoval:
            [mTableView beginUpdates];
            [mTableView removeRowsAtIndexes:indexSet withAnimation:NSTableViewAnimationEffectNone];
            [mTableView endUpdates];
            break;
        case NSKeyValueChangeReplacement:
            [mTableView beginUpdates];
            [mTableView reloadDataForRowIndexes:indexSet columnIndexes:[NSIndexSet indexSetWithIndex:0]];
            [mTableView endUpdates];
            break;
    }
    
}

- (void)_reloadTorqueStatus {
     [self.globalTorqueEnable setState:([Dynamixel sharedInstance].torqueEnabled ? NSOnState : NSOffState )];
}

- (void)_reloadSelectedServoInfo {

    ServoInfo* servo = self.currentServoInfo;
    
    if( nil == servo ) {
        self.enableControl = NO;
        return;
    }
    
    [self.positionIndicator setIntegerValue: servo.position];
    [self.speedIndicator setIntegerValue: servo.speed];
    [self.loadIndicator setIntegerValue:servo.load];
    
    [self.voltageIndicator setIntegerValue:servo.voltage];
    [self.temperatureIndicator setIntegerValue:servo.temperature];
    
    // Move the goal position with the servo if torque is disabled
    // or new ID is selected
    
    if( 0 == servo.torque || _switchingServoSelection )
        [self.goalPositionSlider setIntegerValue:servo.position];
    
    [self.torqueEnable setIntegerValue:servo.torque];
    
    self.enableControl = YES;
    
    _switchingServoSelection = NO;
    
}

- (void)_reloadSelectedMotion {
    
    NSTableView* servoTableView = self.servoValues;
    [servoTableView deselectAll:nil];
    [servoTableView reloadData];
    
}

- (Motion*)currentMotion {
 
    NSTableView* mTableView = self.motionTableView;
    NSInteger index = mTableView.selectedRow;
    NSArray* motions = [self.document motions];
    Motion* m = nil;
    
    if( index >= 0 && index < motions.count ) {
        m = motions[index];
    }
    
    return m;
    
}

- (BOOL)puppetMode {
 
    Dynamixel* d = [Dynamixel sharedInstance];
    if( d.connected && !d.torqueEnabled ) {
        // sync the action only when the droid is connected and the torque is enabled
        return YES;
    } else {
        return NO;
    }
    
}


#pragma mark - tableview datasource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    
    NSInteger count = 0;
    
    if( tableView == self.motionTableView ) {
        count = [self.document motions].count;
    } else {
        NSArray* servos = nil;
        if( [self puppetMode] ) {
            servos = [Dynamixel sharedInstance].allDynamixelServos;
        } else {
            servos = self.currentMotion.motions;
        }
        count = servos.count;
    }
    
    return count;
    
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
 
    NSString* value = nil;
    
    if( tableView == self.motionTableView ) {
        
        NSArray* motions = [self.document motions];
        if( row == motions.count ) {
            value = @"New";
        } else {
            Motion* m = motions[row];
            NSString* name = m.name;
            if( name.length ) {
                value = name;
            } else {
                value = _F(@"Motion %ld", row);
            }
        }
        
    } else {
        
        NSArray* servos = nil;
        if( [self puppetMode] ) {
            servos = [Dynamixel sharedInstance].allDynamixelServos;
        } else {
            servos = self.currentMotion.motions;
        }
        ServoInfo* servo = servos[row];
        NSString* identifier = [tableColumn identifier];
        
        if( [identifier isEqualToString:@"ID"] ) {
            value = [NSString stringWithFormat:@"%ld", servo.sid];
        } else if([identifier isEqualToString: @"Position"]) {
            //        return [[controlTable objectAtIndex: row] objectForKey: [tableColumn identifier]];
            value = [NSString stringWithFormat:@"%ld", servo.position];
        } else if([identifier isEqualToString: @"Speed"] ) {
            value = [NSString stringWithFormat:@"%ld", servo.speed];
        } else if( [identifier isEqualToString:@"Temperature"] ) {
            value = [NSString stringWithFormat:@"%ld", servo.temperature];
        }
        
    }
    
    return value;
}


- (void)tableViewSelectionDidChange:(NSNotification *)notification {

    NSTableView* tableView = notification.object;
    if( tableView == self.motionTableView ) {
        [self _motionSelectionChanged];
    } else {
        [self _servoSelectionChanged];
    }
    
}

-(void)_doubleClickMotion:(id)sender {
 
    NSTableView* tableView = self.motionTableView;
    NSInteger index = [tableView clickedRow];
    
    MotionDocument* mdoc = self.document;
    NSArray* motions = mdoc.motions;
    Motion* m = nil;
    
    if( index >= 0 && index < motions.count ) {
        m = motions[index];
    }

    Dynamixel* d = [Dynamixel sharedInstance];
    [d setMotion:m];
    
}

- (void)_motionSelectionChanged {
    
    NSTableView* tableView = self.motionTableView;
    NSInteger index = [tableView selectedRow];
    
    MotionDocument* mdoc = self.document;
    NSArray* motions = mdoc.motions;
    Motion* m = nil;
    
    if( index >= 0 && index < motions.count ) {
        m = motions[index];
    }
    
    self.currentMotion = m;
    
}

- (void)_servoSelectionChanged {
    
    NSTableView* tableView = self.servoValues;
    NSInteger index = [tableView selectedRow];
    
    NSArray* servos = nil;
    if( [self puppetMode] ) {
        servos = [Dynamixel sharedInstance].allDynamixelServos;
    } else {
        servos = self.currentMotion.motions;
    }

    ServoInfo* s = nil;
    if( index >=0 && index < servos.count ) {
        s = servos[index];
    }
    
    _switchingServoSelection = YES;
    self.currentServoInfo = s;
    
}

- (void)setEnableControl:(BOOL)enable {
    
    if( _enableControl == enable ) {
        return;
    }
    
    _enableControl = enable;
    
    [self.positionIndicator setEnabled: enable];
    [self.speedIndicator setEnabled: enable];
    [self.loadIndicator setEnabled: enable];
    [self.voltageIndicator setEnabled: enable];
    [self.temperatureIndicator setEnabled: enable];
    
    [self.goalPositionSlider setEnabled: enable];
    [self.movingSpeedSlider setEnabled: enable];
    
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

- (IBAction)setGoalPosition:(id)sender {
    
    int p = [self.goalPositionSlider intValue];
    ServoInfo* servo = self.currentServoInfo;
    
    Dynamixel* d = [Dynamixel sharedInstance];
    if ( d.torqueEnabled ) {
        [d setPosition:p ofServo:servo.sid];
    } else {
        servo.position = p;
    }
    
}

- (IBAction)setSpeed:(id)sender {
    
    ServoInfo* servo = self.currentServoInfo;
    
    int s = [self.movingSpeedSlider intValue];
    if(s == 1024) s = 0; // set maximum speed (no speed control) for maximum value

    Dynamixel* d = [Dynamixel sharedInstance];
    if ( d.torqueEnabled ) {
        [d setSpeed:s ofServo:servo.sid];
    } else {
        servo.speed = s;
    }
    
}

- (IBAction)toggleTorque:(id)sender {
    
    BOOL enabled = ([self.globalTorqueEnable state] == NSOnState);
    Dynamixel* d = [Dynamixel sharedInstance];
    if( enabled != d.torqueEnabled ) {
        if( enabled ) {
            [d torqueAllEnable];
        } else {
            // close torque and changed to pupet mode
            [self.motionTableView deselectAll:nil];
            [d torqueAllDisable];
            [self.servoValues reloadData];
        }
    }
   
}

- (IBAction)writeMotionToDroid:(id)sender {
    
    Dynamixel* d = [Dynamixel sharedInstance];
    Motion* m = self.currentMotion;
    if( m ) {
        [d setMotion:m];
    }
    
}

- (IBAction)readMotionFromDroid:(id)sender {
    
    Dynamixel* d = [Dynamixel sharedInstance];
    Motion* m = [d readMotion];
    MotionDocument* mdoc = self.document;
    
    
    NSInteger insertPos = self.motionTableView.selectedRow;
    if( insertPos < 0 ) {
        insertPos = [mdoc.motions count];
    }
    [mdoc insertObject:m inMotionsAtIndex:insertPos];
//    [self.motionTableView deselectAll:nil];
}

- (IBAction)deleteMotion:(id)sender {
    
    NSTableView* mTableView = self.motionTableView;
    NSInteger index = [mTableView selectedRow];
    
    MotionDocument* mdoc = self.document;
    if( index >= 0) {
        [mdoc removeObjectFromMotionsAtIndex:index];
    }
    
}

- (IBAction)playMotion:(id)sender {
    
    NSArray* frames = [self.document motions];
    if( frames.count ) {
        Dynamixel* d = [Dynamixel sharedInstance];
        [d play:frames];
    }
    
}

- (IBAction)loopPlayMotion:(id)sender {
 
    NSArray* frames = [self.document motions];
    NSInteger count = frames.count;
    
    if( count ) {
        NSArray* buf = [frames arrayByAddingObject:@(-count)];
        Dynamixel* d = [Dynamixel sharedInstance];
        [d play:buf];
    }
    
}

- (IBAction)stopPlayMotion:(id)sender {
 
    Dynamixel* d = [Dynamixel sharedInstance];
    [d stop];
    
}

- (IBAction)gotoNextMotion:(id)sender {
 
    NSTableView* mTableView = self.motionTableView;
    NSInteger index = [mTableView selectedRow];
    MotionDocument* mdoc = self.document;
    NSArray* motions = mdoc.motions;
    NSInteger count = motions.count;
    NSInteger next = index+1;
    if( next < count ) {
        [mTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:next] byExtendingSelection:NO];
        Motion* m = motions[next];
        Dynamixel* d = [Dynamixel sharedInstance];
        [d setMotion:m];
    }

    
}

@end
