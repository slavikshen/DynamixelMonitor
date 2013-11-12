//
//  Dynamixel.h
//  DynamixelMonitor
//
//  Created by Slavik on 11/9/13.
//  Copyright (c) 2013 LUCS. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface ServoInfo : NSObject

@property(nonatomic,assign) NSInteger sid;
@property(nonatomic,assign) NSInteger speed;
@property(nonatomic,assign) NSInteger position;
@property(nonatomic,assign) NSInteger load;
@property(nonatomic,assign) NSInteger voltage;
@property(nonatomic,assign) NSInteger temperature;
@property(nonatomic,assign) NSInteger torque;
@property(nonatomic,readonly) unsigned char* servoData;

- (void)updateWithRawData:(unsigned char*)rawData;

@end

@protocol DynamxielJSExport <JSExport>


- (void)setSpeed:(NSInteger)speed ofServo:(NSInteger)servoID;
- (NSInteger)speedOfServo:(NSInteger)servoID;

- (void)setPosition:(NSInteger)pos ofServo:(NSInteger)servoID;
- (NSInteger)positionOfServo:(NSInteger)servoID;

- (void)torqueAllEnable;
- (void)torqueAllDisable;

- (BOOL)connect;
- (void)disconnect;
- (void)update;

- (void)updateServoInfo:(NSInteger)servoID;

- (BOOL)isConnected;
- (BOOL)isTorqueEnabled;

- (void)clearAllTimer;
- (NSInteger)setInterval:(NSTimeInterval)intervale block:(JSValue*)block;
- (void)clearInterval:(NSInteger)intervalId;

@end

@interface Dynamixel : NSObject<DynamxielJSExport>

@property(nonatomic,readonly,getter = isConnected) BOOL connected;
@property(nonatomic,readonly,getter = isTorqueEnabled) BOOL torqueEnabled;

@property(nonatomic,strong) NSMutableDictionary* servos;
@property(nonatomic,readonly,strong) NSArray* allDynamixelServos;
@property(nonatomic,readonly,assign) NSInteger numberOfServos;


+(Dynamixel*)sharedInstance;


@end
