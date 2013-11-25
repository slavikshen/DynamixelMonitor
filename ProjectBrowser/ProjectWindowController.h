//
//  ProjectWindowController.h
//  DynamixelMonitor
//
//  Created by Slavik on 11/16/13.
//  Copyright (c) 2013 LUCS. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "LogTextView.h"
#import "JSWrapper.h"
#import "DocumentViewController.h"

@interface ProjectWindowController : NSWindowController<NSOutlineViewDelegate,NSSplitViewDelegate>

@property(nonatomic,strong) IBOutlet NSOutlineView* outlineView;
@property(nonatomic,strong) IBOutlet NSView* contentView;

@property(nonatomic,strong) NSImage* folderIcon;
@property(nonatomic,strong) NSImage* projectIcon;

@property(nonatomic,strong) DocumentViewController* currentEditorController;

@property(nonatomic,assign,getter = isRunning) BOOL running;
@property(nonatomic,strong) IBOutlet NSToolbarItem* runToolbarItem;
@property(nonatomic,strong) IBOutlet NSToolbarItem* stopToolbarItem;

@property(nonatomic,strong) IBOutlet NSSplitView* editorSplitView;

@property(nonatomic,strong) IBOutlet LogTextView* logView;
@property(nonatomic,strong) JSWrapper* jsWrapper;

@property(nonatomic,strong) IBOutlet NSMenu* outlineItemMenu;
@property(nonatomic,strong) IBOutlet NSToolbarItem* connectToolbarItem;

- (IBAction)saveDocument:(id)sender;
- (IBAction)showInFinder:(id)sender;
- (IBAction)deleteDocument:(id)sender;


@end
