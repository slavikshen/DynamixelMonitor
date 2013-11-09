//
//  NSLogTextView.h
//  DynamixelMonitor
//
//  Created by Slavik on 11/3/13.
//  Copyright (c) 2013 LUCS. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol LogTextViewExport <JSExport>

-(void)log:(NSString*)string;

@end

@interface LogTextView : NSTextView<LogTextViewExport>

@end
