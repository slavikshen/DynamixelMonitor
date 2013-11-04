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
 
    self.backgroundColor = [NSColor blackColor];
    self.textColor = [NSColor lightGrayColor];
    self.font = [NSFont systemFontOfSize:14];
    
}

@end
