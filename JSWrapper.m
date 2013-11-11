//
//  JSWrapper.m
//  DynamixelMonitor
//
//  Created by Slavik on 11/4/13.
//  Copyright (c) 2013 LUCS. All rights reserved.
//

#import "JSWrapper.h"
#import "WebView+LoadBundle.h"
#import "LogTextView.h"
#import "Console.h"
#import "Dynamixel.h"

@implementation JSWrapper

+ (JSWrapper*)sharedInstance {
    
    static JSWrapper* inst = nil;
    if( nil == inst ) {
        inst = [[JSWrapper alloc] init];
    }
    return inst;
    
}

- (id)init {
 
    self = [super init];
    [self _setup];
    return self;
    
}

- (void)_setup {

    JSContext* context = [[JSContext alloc] init];
    context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        NSLog(@"JS Exception\n%@",exception);
    };
    
    __block JSWrapper* s = self;
    context[@"setInterval"] = ^(JSValue* block, float interval) {
        NSLog(@"function callback\n%@", block);
        return [s.dynamixel setInterval:interval block:block];
    };
    self.jsContext = context;
    
//    context[@"console"] = [[Console alloc] init];
    
}

- (void)setLogView:(LogTextView *)logView {
 
    _logView = logView;
    self.jsContext[@"console"] = logView;
    
}

- (void)setDynamixel:(Dynamixel *)dynamixel {
    _dynamixel = dynamixel;
    self.jsContext[@"D"] = dynamixel;
    self.jsContext[@"Dynamxil"] = dynamixel;
    self.jsContext[@"window"] = dynamixel;
}


- (void)evalScript:(NSString*)script {
    
    [self.dynamixel clearAllTimer];
    NSLog(@"eval script\n%@",script);
    id ret = [self.jsContext evaluateScript:script];
    NSLog(@"js ret\n%@", ret);
}

- (void)stopScript {

    [self.dynamixel clearAllTimer];
    
}

//-(void)log:(NSString*)string {
//    
//    NSLog(@"jslog: %@", string);
//    NSTextView* logView = self.logTextView;
//    NSUInteger p = [[[logView textStorage] string] length];
//    [logView setSelectedRange:NSMakeRange(p, p)];
//    [logView insertText: string];
//    [logView insertText: @"\n"];
//    
//}

@end



