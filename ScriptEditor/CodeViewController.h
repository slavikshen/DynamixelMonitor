//
//  CodeViewController.h
//  DynamixelMonitor
//
//  Created by Slavik on 11/16/13.
//  Copyright (c) 2013 LUCS. All rights reserved.
//

#import "DocumentViewController.h"

@interface CodeViewController : DocumentViewController<NSSplitViewDelegate>

@property(nonatomic,strong) IBOutlet NSView* editorContainer;

@end
