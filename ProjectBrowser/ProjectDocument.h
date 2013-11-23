//
//  ProjectDocument.h
//  DynamixelMonitor
//
//  Created by Slavik on 11/14/13.
//  Copyright (c) 2013 LUCS. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ProjectDocument : NSDocument<NSWindowDelegate,NSPageControllerDelegate>

@property(nonatomic,strong) IBOutlet NSOutlineView* outlineView;
@property(nonatomic,strong) IBOutlet NSPageController* pageController;
@property(nonatomic,strong) IBOutlet NSTreeController* treeController;

@end
