//
//  NSLogTextView.m
//  DynamixelMonitor
//
//  Created by Slavik on 11/3/13.
//  Copyright (c) 2013 LUCS. All rights reserved.
//

#import "LogTextView.h"

@implementation LogTextView


- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    [self _setup];
    
    return self;
    
}

- (void)_setup {
 
    self.backgroundColor = [NSColor colorWithWhite:0.1 alpha:1];
    self.textColor = [NSColor lightGrayColor];
    
}


-(void)log:(NSString*)string {
    
    NSLog(@"jslog: %@", string);

    NSTextStorage* mstr = [self textStorage];
    NSUInteger p = [mstr length];
    
    [self setEditable:YES];
    [self setSelectedRange:NSMakeRange(p, p)];
    [self insertText: @"\n"];
    [self insertText:string replacementRange:NSMakeRange(p, p)];
    [self setEditable:NO];
    
}

@end
