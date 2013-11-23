//
//  JSWrapper.m
//  DynamixelMonitor
//
//  Created by Slavik on 11/4/13.
//  Copyright (c) 2013 LUCS. All rights reserved.
//

#import "JSWrapper.h"
#import "LogTextView.h"
#import "Console.h"
#import "Dynamixel.h"

@interface JSWrapper()

@property(nonatomic,readwrite,copy) NSString* projectPath;

@end

@implementation JSWrapper

@dynamic isConnected;

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

- (id)initWithProject:(ProjectDocument*)pDoc {
    
    self = [super init];
    if( self ) {
        [self _setup];
        NSString* filepath = pDoc.fileURL.path;
        NSString* runningPath = [filepath stringByDeletingLastPathComponent];
        self.projectPath = runningPath;
    }
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
    context[@"evalFile"] = ^(NSString* filePath) {
        [self evalFile:filePath];
    };
    self.jsContext = context;
    
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

- (BOOL)evalFile:(NSString*)path {

    NSString* script = nil;
    // locate the file
    NSFileManager* fm = [NSFileManager defaultManager];
    
    NSArray* scanPath = nil;
    NSString* projectPath = self.projectPath;
    
    if( projectPath ) {
        
        static NSArray* PATHES = nil;
        if( nil == PATHES ) {
            PATHES = @[@"",
                       @"scripts",
                       @"modules"];
        }
        
        NSMutableArray* buf = [NSMutableArray arrayWithCapacity:PATHES.count];
        for( NSString* p in PATHES ) {
            NSString* absPath = [[projectPath stringByAppendingPathComponent:p]
                                              stringByAppendingPathComponent:path];
            [buf addObject:absPath];
        }
        
        scanPath = buf;
        
    } else {
        scanPath = @[path];
    }
    
    for( NSString* p in scanPath ) {
        BOOL isDir = NO;
        if( [fm fileExistsAtPath:p isDirectory:&isDir] ) {
            if( !isDir ) {
                // eval the file
                NSError* err = nil;
                script = [NSString stringWithContentsOfFile:p encoding:NSUTF8StringEncoding error:&err];
                break;
            }
        }
    }
    
    if( script ) {
        [self evalScript:script];
        return YES;
    }
    
    
    return NO;
}


- (void)evalScript:(NSString*)script {
    
    if( ![self.dynamixel isConnected] ) {
        [self.dynamixel connect];
    }
    [self.dynamixel clearAllTimer];
    NSLog(@"eval script\n%@",script);
    id ret = [self.jsContext evaluateScript:script];
    NSLog(@"js ret\n%@", ret);
}

- (void)stopScript {

    [self.dynamixel stop];
    
}

- (BOOL)isConnected {
    return [self.dynamixel isConnected];
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



