//
//  ProjectDocument.h
//  DynamixelMonitor
//
//  Created by Slavik on 11/14/13.
//  Copyright (c) 2013 LUCS. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ProjectItem.h"

APPKIT_EXTERN NSString* const ProjectDocumentProperty_FileURL;

@interface ProjectDocument : NSDocument<NSWindowDelegate,NSOutlineViewDataSource>

@property(nonatomic,strong) IBOutlet NSOutlineView* outlineView;

@property(nonatomic,copy) NSString* projectName;
@property(nonatomic,copy) NSString* authorName;

@property(nonatomic,strong) ProjectItem* projectItem;

@end
