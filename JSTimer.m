//
//  JSTimer.m
//  DynamixelMonitor
//
//  Created by Slavik on 11/10/13.
//  Copyright (c) 2013 LUCS. All rights reserved.
//

#import "JSTimer.h"

@interface JSTimer()

@property(nonatomic,strong) NSTimer* timer;

@end

@implementation JSTimer

- (void)start {
    
    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:self.interval target:self selector:@selector(_timer) userInfo:nil repeats:self.repeat];
    self.timer = timer;
    
}

- (void)stop {
    
    [self.timer invalidate];
    self.timer = nil;
}

- (void)_timer {
    
    [self.callback callWithArguments:nil];
    
}

@end
