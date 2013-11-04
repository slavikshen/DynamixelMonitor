//
//  ScriptTextView.m
//  DynamixelMonitor
//
//  Created by Slavik on 11/3/13.
//  Copyright (c) 2013 LUCS. All rights reserved.
//

#import "ScriptTextView.h"

@implementation ScriptTextView

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    [self _setup];
    
    return self;
    
}

- (void)_setup {
    
    self.backgroundColor = [NSColor whiteColor];
    self.textColor = [NSColor textColor];
    self.font = [NSFont systemFontOfSize:14];
    
}

@end
