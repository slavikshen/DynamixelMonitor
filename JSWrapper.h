//
//  JSWrapper.h
//  DynamixelMonitor
//
//  Created by Slavik on 11/4/13.
//  Copyright (c) 2013 LUCS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LogTextView;
@class Dynamixel;

@interface JSWrapper : NSObject

@property(nonatomic,strong) IBOutlet LogTextView* logView;
@property(nonatomic,strong) JSContext* jsContext;
@property(nonatomic,strong) Dynamixel* dynamixel;

- (void)evalScript:(NSString*)script;
- (void)stopScript;

+ (JSWrapper*)sharedInstance;




@end
