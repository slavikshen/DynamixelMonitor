//
//  ScriptDocument.h
//  DynamixelMonitor
//
//  Created by Slavik on 11/11/13.
//  Copyright (c) 2013 LUCS. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LogTextView.h"
#import "JSWrapper.h"

@interface ScriptDocument : NSDocument

@property(nonatomic,assign,getter = isRunning) BOOL running;

@property(nonatomic,strong) IBOutlet NSView* editorContainer;
@property(nonatomic,strong) IBOutlet LogTextView* logView;

@property(nonatomic,strong) IBOutlet JSWrapper* jsWrapper;

@property(nonatomic,strong) IBOutlet NSSplitView* splitView;

@property(nonatomic,strong) IBOutlet NSToolbarItem* runToolbarItem;

- (IBAction)runOrStop:(id)sender;

@end
