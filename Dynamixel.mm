//
//  Dynamixel.m
//  DynamixelMonitor
//
//  Created by Slavik on 11/9/13.
//  Copyright (c) 2013 LUCS. All rights reserved.
//

#import "Dynamixel.h"
#import "JSTimer.h"
#include "DynamixelComm.h"


@implementation ServoInfo {
 
    unsigned char _servoData[128];
    
}

@dynamic servoData;

- (unsigned char*)servoData {
    return _servoData;
}

- (void)updateWithRawData:(unsigned char*)rawData {
    
    unsigned char* servoData = _servoData;
    
    memcpy(servoData,rawData,sizeof(unsigned char)*128);
    
    int position = servoData[P_PRESENT_POSITION_L]+256*servoData[P_PRESENT_POSITION_H];
    unsigned int speed = servoData[P_PRESENT_SPEED_L]+256*servoData[P_PRESENT_SPEED_H];
    if( speed >= 1024 ) {
        speed -= 1024;
    }
    int load = servoData[P_PRESENT_LOAD_L]+256*servoData[P_PRESENT_LOAD_H];
    if(load >= 1024) load -= 1024;

    int voltage = servoData[P_PRESENT_VOLTAGE];
    int temperature = servoData[P_PRESENT_TEMPERATURE];
    int torque = servoData[P_TORQUE_ENABLE];

    self.position = position;
    self.speed = speed;
    self.load = load;
    self.voltage = voltage;
    self.temperature = temperature;
    self.torque = torque;
        
}

@end

@interface Dynamixel()

@property(nonatomic,readwrite,strong) NSArray* allDynamixelServos;
@property(nonatomic,readwrite,getter = isConnected) BOOL connected;
@property(nonatomic,readwrite,getter = isTorqueEnabled) BOOL torqueEnabled;

@property(nonatomic,strong) NSMutableDictionary* timers;
@property(nonatomic,assign) NSInteger lastTimerIndex;

@end

@implementation Dynamixel {
    
    DynamixelComm * dc;
    
}

@dynamic numberOfServos;

+(Dynamixel*)sharedInstance {
 
    static Dynamixel* inst = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if( nil == inst ) {
            inst = [[Dynamixel alloc] init];
        }
    });
    return inst;
}

- (id)init {
 
    self = [super init];
    [self _setup];
    return self;
    
}

- (void)_setup {
    self.servos = [NSMutableDictionary dictionaryWithCapacity:128];
    self.timers = [NSMutableDictionary dictionaryWithCapacity:128];
    self.frameInterval = 1;
}


- (BOOL)connect {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *device = [defaults stringForKey:@"device"];
    if(device == nil) device = @"/dev/cu.usbserial-A7005Lxn";
    
    [self.servos removeAllObjects];
    self.allDynamixelServos = nil;
    
    if ([self isConnected]) {
        return self.connected;
    }
    
    if(!dc)
    {
        NSLog(@"Connecting Dynamxiel");
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
            self.connected = NO;
            return NO;
        }
        
        // Scan for dynamixels
        NSMutableArray* all = [[NSMutableArray alloc] initWithCapacity:32];

        for(int i=0; i<32; i++)
        {
            if(dc->Ping(i))
            {
                ServoInfo* servo = [[ServoInfo alloc] init];
                servo.sid = i;
                self.servos[@(i)] = servo;
                [all addObject:servo];
            }
        }
        
        self.allDynamixelServos = all;
        
        self.connected = YES;
    }
    
    
    return self.connected;
}

- (void)disconnect {

    if ([self isConnected]) {
        NSLog(@"Dynamixel disconnected");
        delete dc;
        dc = NULL;
        self.connected = NO;
    }
    
}

- (void)update {
    
    NSArray* ids = self.servos.allKeys;
    
    for( NSNumber* idNum in ids ) {

        NSInteger sid = [idNum integerValue];
        
        unsigned char servoData[128];
        dc->ReadAllData(sid, servoData);
        
        ServoInfo* servo = self.servos[idNum];
        [servo updateWithRawData:servoData];
        
    }
    
}

- (void)setSpeed:(NSInteger)speed ofServo:(NSInteger)servoID {
    
    ServoInfo* servo = self.servos[@(servoID)];
    int s = speed;
    if(s == 1024) s = 0; // set maximum speed (no speed control) for maximum value
    
    int sid = servoID;
    servo.speed = s;
    
    dc->SetSpeed( sid, s );
    
}

- (NSInteger)speedOfServo:(NSInteger)servoID {
    ServoInfo* servo = self.servos[@(servoID)];
    return servo.speed;
}

- (void)setPosition:(NSInteger)position {

    for( ServoInfo* servo in self.allDynamixelServos ) {
        servo.position = position;
        dc->SetPosition(servo.sid, position);
    }
    
}


- (void)setPosition:(NSInteger)pos ofServo:(NSInteger)servoID {
    
    ServoInfo* servo = self.servos[@(servoID)];
    int p = pos;
    int s = servo.speed;
    if( 0 == s || s == 1024 ) {
        s = self.speed;
    }
    servo.position = pos;
    
    int sid = servoID;
    dc->Move(sid, p, s);
}

- (NSInteger)positionOfServo:(NSInteger)servoID {
    ServoInfo* servo = self.servos[@(servoID)];
    return servo.position;
}


- (void)torqueAllEnable {
    
    dc->SetTorque(254, 1);
    self.torqueEnabled = YES;
    
}

- (void)torqueAllDisable {
    
    dc->SetTorque(254, 0);
    self.torqueEnabled = NO;
}

- (void)updateServoInfo:(NSInteger)servoID {

    ServoInfo* servo = self.servos[@(servoID)];
    unsigned char servoData[128];
    dc->ReadAllData(servoID, servoData);
    
    [servo updateWithRawData:servoData];
    
}

- (NSInteger)numberOfServos {
    return self.allDynamixelServos.count;
}

- (void)clearAllTimer {
    
    NSArray* allKeys = [self.timers allKeys];
    for( NSNumber* k in allKeys ) {
        JSTimer* timer = [self.timers objectForKey:k];
        [timer stop];
    }
    
    [self.timers removeAllObjects];
}

- (NSInteger)setInterval:(NSTimeInterval)intervale block:(JSValue*)block {
    
    NSInteger tid = self.lastTimerIndex+1;
    self.lastTimerIndex = tid;
    
    JSTimer* timer = [[JSTimer alloc]init];
    timer.callback = block;
    timer.interval = intervale/1000;
    timer.repeat = YES;
    
    self.timers[@(tid)] = timer;
    [timer start];
    
    return tid;
}

- (void)clearInterval:(NSInteger)intervalId {
    
    NSNumber* key = @(intervalId);
    JSTimer* timer = self.timers[key];
    [timer stop];
    [self.timers removeObjectForKey:key];
    
}

- (void)setStatus:(NSDictionary*)positions {

    for( NSString* key in positions ) {
        
        id value = positions[key];
        NSInteger sid = [key integerValue];
        
        if( [value isKindOfClass:[NSNumber class]] )  {
            NSInteger pos = [value integerValue];
            [self setPosition:pos ofServo:sid];
        } else {
            NSLog(@"key: %@\nvalue: %@", key, value);
        }
        
    }
    
}

- (void)play:(NSArray*)frames {
    
    // create a timer for this
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_playNextFrame) object:nil];
    
    self.currentFrames = frames;
    self.currentFrameIndex = 0;
    
    [self performSelector:@selector(_playNextFrame) withObject:nil afterDelay:self.frameInterval];
    
}

- (void)_playNextFrame {
 
    NSInteger currIndex = self.currentFrameIndex;
    NSInteger count = self.currentFrames.count;
    
    if( currIndex < count ) {

        id value = self.currentFrames[currIndex];
        
        if( [value isKindOfClass:[NSNumber class]] ) {
            NSInteger cmd = [value integerValue];
            currIndex += cmd;
            if( currIndex < 0 ) {
                currIndex = 0;
            } else if (currIndex>count) {
                currIndex = count-1;
            }
            value = self.currentFrames[currIndex++];
        } else {
            currIndex++;
        }

        
        if( [value isKindOfClass:[NSDictionary class]] ) {
            NSDictionary* postions = value;
            [self setStatus:postions];
        }
        
        self.currentFrameIndex = currIndex;
        if( currIndex < count ) {
            [self performSelector:@selector(_playNextFrame) withObject:nil afterDelay:self.frameInterval];
        }
    }
    
}

- (void)stop {
    [self clearAllTimer];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_playNextFrame) object:nil];
}

@end
