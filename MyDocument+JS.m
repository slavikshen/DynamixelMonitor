//
//  MyDocument+JS.m
//  DynamixelMonitor
//
//  Created by Slavik on 11/3/13.
//  Copyright (c) 2013 LUCS. All rights reserved.
//

#import "MyDocument+JS.h"
#import "JSWrapper.h"

@implementation MyDocument (JS)

- (void)loadJSContext {
    
    JSWrapper* wrapper = [[JSWrapper alloc] init];
    wrapper.logView = (LogTextView*)(self.logView);
    self.jsWrapper = wrapper;
    
    
}

- (void)releaseJSContext {
    
    self.jsWrapper = nil;
    
}


- (void)evalScript:(NSString*)js {
    [self.jsWrapper evalScript:js];
}

@end
