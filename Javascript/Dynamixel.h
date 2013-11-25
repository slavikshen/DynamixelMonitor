//
//  Dynamixel.h
//  DynamixelMonitor
//
//  Created by Slavik on 11/9/13.
//  Copyright (c) 2013 LUCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MotionDocument.h"

APPKIT_EXTERN NSString* const kDynamixelProperty_Connected;
APPKIT_EXTERN NSString* const kDynamixelProperty_TorqueEnabled;

@interface ServoInfo : NSObject<NSCopying,NSCoding>

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


@property(nonatomic,assign) NSInteger speed;
@property(nonatomic,assign) NSTimeInterval frameInterval;

- (void)setPosition:(NSInteger)position;

- (void)setSpeed:(NSInteger)speed ofServo:(NSInteger)servoID;
- (NSInteger)speedOfServo:(NSInteger)servoID;

- (void)setPosition:(NSInteger)pos ofServo:(NSInteger)servoID;
- (NSInteger)positionOfServo:(NSInteger)servoID;

- (void)setStatus:(NSDictionary*)positions;
- (void)play:(NSArray*)frames;

- (void)torqueAllEnable;
- (void)torqueAllDisable;

- (BOOL)connect;
- (void)disconnect;
- (void)update;

- (void)updateServoInfo:(NSInteger)servoID;

- (BOOL)isConnected;
- (BOOL)isTorqueEnabled;

- (void)stop;
- (void)clearAllTimer;
- (NSInteger)setInterval:(NSTimeInterval)intervale block:(JSValue*)block;
- (void)clearInterval:(NSInteger)intervalId;



@end

@interface Dynamixel : NSObject<DynamxielJSExport>

@property(nonatomic,assign) NSInteger speed;
@property(nonatomic,assign) NSTimeInterval frameInterval;

@property(nonatomic,readonly,getter = isConnected) BOOL connected;
@property(nonatomic,readonly,getter = isTorqueEnabled) BOOL torqueEnabled;

@property(nonatomic,strong) NSMutableDictionary* servos;
@property(nonatomic,readonly,strong) NSArray* allDynamixelServos;
@property(nonatomic,readonly,assign) NSInteger numberOfServos;

@property(nonatomic,strong) NSArray* currentFrames;
@property(nonatomic,assign) NSUInteger currentFrameIndex;

+(Dynamixel*)sharedInstance;

- (void)setMotion:(Motion*)m;
- (Motion*)readMotion;

@end
