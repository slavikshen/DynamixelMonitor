//
//  JSTimer.h
//  DynamixelMonitor
//
//  Created by Slavik on 11/10/13.
//  Copyright (c) 2013 LUCS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSTimer : NSObject

@property(nonatomic,assign) NSTimeInterval interval;
@property(nonatomic,strong) JSValue* callback;
@property(nonatomic,assign) BOOL repeat;

- (void)start;
- (void)stop;

@end
